const guid = (): string => {
  const s4 = () => {
    return Math.floor((1 + Math.random()) * 0x10000)
               .toString(16)
               .substring(1);

  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
         s4() + '-' + s4() + s4() + s4();
};

var user = function user() {
    var storageKey = "__catsocket_user_id";

    // TODO - use cookies instead of localStorage
    var key = window.localStorage.getItem(storageKey);
    if (key) {
        return key;
    } else {
        key = guid();
        window.localStorage.setItem(storageKey, key);
        return key;
    }
};

var removeValue = function<T>(arr: T[], value: T) {
    var index = arr.indexOf(value);
    if (index !== -1) {
        arr.splice(index, 1);
    }
};

const DEBUG_SERVER: boolean = true;

interface CatsocketOptions {
  user_id: string;
  host: string;
  production: boolean;
  status_changed: any;
}

interface CatsocketMessage {
  data: any;
}

const defaultOptions: CatsocketOptions = {
  production: true,
  user_id: null,
  host: null,
  status_changed: null,
}

const catsocket = {
  init(api_key: string, options: CatsocketOptions = defaultOptions) {
    var host = options["host"];

    // TODO - asssert that API key exists
    const user_id = options.user_id || guid();
    if (DEBUG_SERVER && !options["production"]) {
        host = host || "ws://localhost:9000";
    } else {
        host = host || "wss://catsocket.com";
    }

    const status_changed = options.status_changed || function() {};
    const cat = new CatSocket(api_key, user_id, host, status_changed);
    cat.connect();

    cat.log_debug("Trying to connect...", null);

    return cat;
  }
};

/** @define {boolean} */

/** @constructor */
class CatSocket {
  public socket: string;
  public is_identified: any;
  public is_connected: any;
  public user_id: any;
  public host: any;
  public api_key: any;
  public handlers: any;
  public queue: any;
  public sent_messages: any;
  public joined_rooms: any;
  public silent: boolean;
  public debug: boolean;
  public status_changed: any;

  constructor(api_key: string, user_id: string, host: string, status_changed: any) {
    this.silent = false;
    this.debug = false;

    if (!api_key) { throw new Error("API key is required."); }

    this.socket = null;
    this.is_identified = false;
    this.is_connected = false;
    this.user_id = user_id;
    this.host = host;
    this.api_key = api_key;
    // room<->handler mapping for received messages
    this.handlers = {};
    this.queue = [];
    this.sent_messages = [];
    this.joined_rooms = [];
    this.status_changed = status_changed;

    this._startTimer();

    return this;
  }

  /** @type {function(...*)} */
  log = function () {
    if (!this.silent) {
      console.log.apply(console, arguments);
    }
  };

  /** @type {function(...*)} */
  log_debug = function (a: any, b: any) {
    if (this.debug) {
      console.log.apply(console, arguments);
    }
  };

  connect = function () {
    // Close the previous connection if there was one
    if (this.socket) {
      this.socket.close();
    }

    this.is_identified = false;
    this.is_connected = false;

    this["status_changed"]("connecting");
    var url = this.host + "/b/ws";
    this.socket = new WebSocket(url);
    this._setHandlers(this.socket);
  };

  _setHandlers = function (socket: WebSocket) {
    socket.onopen = function () {
      this["status_changed"]("connected");
      this.is_connected = true;
      this.send("identify", {});
    }.bind(this);

    socket.onclose = function () {
      if (this.force_close) {
        this.log_debug("Socket was explicitly closed, not reconnecting.");
      } else {
        this.is_connected = false;
        this.is_identified = false;

        setTimeout(this.connect.bind(this), 2000);
      }

      this["status_changed"]("closed");
    }.bind(this);

    socket.onmessage = function(message: CatsocketMessage) {
      // if (this["debug"]) console.group("onmessage");

      // TODO - check if there is something else on the message that could be used/inspected?
      var event = JSON.parse(message["data"]);

      switch (event["action"]) {
        case "message":
          this._handleMessage(event);
        break;
        case "ack":
          this._handleAck(event);
        break;
        default:
          this._unrecognizedMessage(event);
      }

      // if (this["debug"]) console.groupEnd();
    }.bind(this);
  };

  send = function (action: string, data: any) {
    var params = {
      "api_key": this.api_key,
      "user": this.user_id,
      "id": guid(),
      "data": data,
      "action": action,
      "timestamp": new Date().getTime()
    };

    this._doSend(params);
  };

  _doSend = function (params) {
    if (this.is_connected && (this.is_identified || params["action"] == "identify")) {
      this.log_debug("->", params);
      this.sent_messages[params["id"]] = params;

      this.socket.send(JSON.stringify(params));
    } else {
      this.log_debug("Pushing to queue", params);
      this.queue.push(params);
    }
  };

  flushQueue = function () {
    this.log_debug("flushing queue");

    while (this.queue.length) {
      var item = this.queue.pop();
      this._doSend(item);
    }
  };

  _handleMessage = function (event) {
    if (event["data"]["room"]) {
      var handler = this.handlers[event["data"]["room"]];

      if (typeof handler === "function") {
        if (event["data"]["message"]) {
          handler.call(null, event["data"]["message"]);
        } else {
          console.error("Missing message in `event.data.message`", event);
        }
      } else {
        this.log("Received message for which there is no handler", event);
      }
    } else {
      console.error("Invalid message, missing `event.data.room`", event);
    }
  };

  _handleAck = function (event) {
    var sent_message = this.sent_messages[event["id"]];

    if (sent_message) {
      if (sent_message["action"] === "identify") {
        this["status_changed"]("identified");
        this.is_identified = true;
        this.flushQueue();
        this._joinRooms();
      }

      this.log_debug("<- ACK:", sent_message["id"], sent_message);
      delete this.sent_messages[event["id"]];
    } else {
      console.error("Received ACK for message which wasn't sent", event["id"], event);
    }
  };

  _unrecognizedMessage = function (event) {
    console.error("Unrecognized message type", event["action"], "with data", event);
  };

  _joinRooms = function () {
    for (var i = 0; i < this.joined_rooms.length; i++) {
      var room = this.joined_rooms[i];
      // We're sending here explicitly to avoid adding the same room to `this.joined_rooms` again.
      this.log_debug("TODO - fix re-joining", room);
      // this.send("join", {"room": room});
    }
  };

  join = function (room, handler, last_timestamp) {
    if (handler) {
      this.handlers[room] = handler;
    }

    this.joined_rooms.push(room);

    this.send("join", {
      "room": room,
      "last_timestamp": last_timestamp
    });
  };

  leave = function (room) {
    removeValue(this.joined_rooms, room);
    delete this.handlers[room];
    this.send("leave", {"room": room});
  };

  broadcast = function (room: string, message: CatsocketMessage) {
    this.send("broadcast", {"room": room, "message": message});
  };

  close = function () {
    this.force_close = true;
    this.is_connected = false;
    this.is_identified = false;
    this.socket.close();

    this.log_debug("Socket closed...");
  };

  _startTimer = function () {
    this["_timer_interval"] = setInterval(function () {
      this.log_debug("timer ticks");
      var now = +new Date();

      var RESEND_TIMEOUT = 10000;

      var to_delete = [];
      var to_keep = {};

      for (var id in this.sent_messages) {
        if (this.sent_messages.hasOwnProperty(id)) {
          var message = this.sent_messages[id];

          if (message.timestamp + RESEND_TIMEOUT < now) {
            to_delete.push(message);
          } else {
            to_keep[id] = message;
          }
        }
      }

      this.sent_messages = to_keep;

      for (var i = 0; i < to_delete.length; i++) {
        var message = to_delete[i];
        this.log_debug("Timer sending", message);
        this._doSend(message);
      }

    }.bind(this), 2000);
  };

}

export default catsocket;
