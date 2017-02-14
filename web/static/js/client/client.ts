interface StatusChangedHandler {
  (status: Status): void;
}

interface MessageHandler {
  (message: ReceivedMessage): void;
}

interface CatsocketOptions {
  user_id?: string;
  host?: string;
  production: boolean;
  status_changed?: StatusChangedHandler;
}

type ClientAction = "join" | "leave" | "broadcast" | "identify";
interface ClientMessage {
  id: string;
  action: ClientAction;
};

type ReceivedAction = "message" | "ack";
interface ReceivedMessage {
  data: any;
  api_key: string;
  user: string;
  id: string;
  action: ReceivedAction;
  timestamp: number
}

type Status = "connecting" | "connected" | "identified";

const guid = (): string => {
  const s4 = () => {
    return Math.floor((1 + Math.random()) * 0x10000)
               .toString(16)
               .substring(1);

  }
  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
         s4() + '-' + s4() + s4() + s4();
};

const user = () => {
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

const removeValue = function<T>(arr: T[], value: T) {
    var index = arr.indexOf(value);
    if (index !== -1) {
        arr.splice(index, 1);
    }
};

const DEBUG_SERVER: boolean = true;

const defaultOptions: CatsocketOptions = {
  production: true,
  user_id: null,
  host: null,
  status_changed: (status) => {},
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

    const status_changed: StatusChangedHandler = options.status_changed || function() {};
    const cat = new CatSocket(api_key, user_id, host, status_changed);
    cat.connect();

    cat.log_debug("Trying to connect...", null);

    return cat;
  }
};

class MessageSender {
  public cat: CatSocket;

  constructor(cat: CatSocket) {
    this.cat = cat;
    this._startTimer();
  }

  send(action: ClientAction, data: any) {
    var params = {
      "id": guid(),
      "data": data,
      "action": action,
      "user": this.cat.user_id,
      "api_key": this.cat.api_key,
      "timestamp": new Date().getTime()
    };

    this._doSend(params);
  };

  _doSend(params: ClientMessage) {
    if (this.cat.is_connected && (this.cat.is_identified || params.action == "identify")) {
      this.cat.log_debug("->", params);
      this.cat.sent_messages[params.id] = params;

      this.cat.socket.send(JSON.stringify(params));
    } else {
      this.cat.log_debug("Pushing to queue", params);
      this.cat.queue.push(params);
    }
  };

  flushQueue() {
    this.cat.log_debug("flushing queue", null);

    while (this.cat.queue.length) {
      var item = this.cat.queue.pop();
      this._doSend(item);
    }
  };


  _joinRooms() {
    for (var i = 0; i < this.cat.joined_rooms.length; i++) {
      var room = this.cat.joined_rooms[i];
      // We're sending here explicitly to avoid adding the same room to `this.joined_rooms` again.
      this.cat.log_debug("TODO - fix re-joining", room);
      // this.send("join", {"room": room});
    }
  };

  join(room: string, handler: any, last_timestamp?: number) {
    if (handler) {
      this.cat.handlers[room] = handler;
    }

    this.cat.joined_rooms.push(room);

    this.send("join", {
      "room": room,
      "last_timestamp": last_timestamp
    });
  };

  leave(room: string) {
    removeValue(this.cat.joined_rooms, room);
    delete this.cat.handlers[room];
    this.send("leave", {"room": room});
  };

  broadcast(room: string, message: any) {
    this.send("broadcast", {"room": room, "message": message});
  };

  close() {
    this.cat.force_close = true;
    this.cat.is_connected = false;
    this.cat.is_identified = false;
    this.cat.socket.close();

    this.cat.log_debug("Socket closed...", null);
  };

  _startTimer() {
    this.cat._timer_interval = setInterval(function () {
      this.log_debug("timer ticks");
      var now = +new Date();

      var RESEND_TIMEOUT = 10000;

      var to_delete = [];
      var to_keep: any = {};

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

class MessageProcessor {
  public cat: CatSocket;
  public sender: MessageSender;

  constructor(cat: CatSocket, sender: MessageSender){
    this.cat = cat;
    this.sender = sender;
  }

  handleMessage(event: ReceivedMessage) {
    if (event["data"]["room"]) {
      var handler = this.cat.handlers[event["data"]["room"]];

      if (typeof handler === "function") {
        if (event["data"]["message"]) {
          handler.call(null, event["data"]["message"]);
        } else {
          console.error("Missing message in `event.data.message`", event);
        }
      } else {
        this.cat.log("Received message for which there is no handler", event);
      }
    } else {
      console.error("Invalid message, missing `event.data.room`", event);
    }
  };

  handleAck(event: ReceivedMessage) {
    var sent_message = this.cat.sent_messages[event["id"]];

    if (sent_message) {
      if (sent_message["action"] === "identify") {
        this.cat.status_changed("identified");
        this.cat.is_identified = true;
        this.sender.flushQueue();
        this.sender._joinRooms();
      }

      this.cat.log_debug("<- ACK:", sent_message["id"], sent_message);
      delete this.cat.sent_messages[event["id"]];
    } else {
      console.error("Received ACK for message which wasn't sent", event["id"], event);
    }
  };

  unrecognizedMessage(event: ReceivedMessage) {
    console.error("Unrecognized message type", event["action"], "with data", event);
  };
}

/** @constructor */
class CatSocket {
  public socket:WebSocket;
  public is_identified: any;
  public is_connected: any;
  public user_id: any;
  public host: any;
  public api_key: any;
  // TODO
  // public handlers: MessageHandler[];
  public handlers: any;
  public queue: any;
  public sent_messages: any;
  public joined_rooms: any;
  public silent: boolean;
  public debug: boolean;
  public status_changed: StatusChangedHandler;

  public sender: MessageSender;

  public force_close: boolean;
  public _timer_interval: number;

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

    this.sender = new MessageSender(this);
  }

  connect() {
    // Close the previous connection if there was one
    if (this.socket) {
      this.socket.close();
    }

    this.is_identified = false;
    this.is_connected = false;

    this.status_changed("connecting");
    var url = this.host + "/b/ws";
    this.socket = new WebSocket(url);
    this._setHandlers(this.socket);
  };

  _setHandlers(socket: WebSocket) {
    socket.onopen = function () {
      this.status_changed("connected");
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

      this.status_changed("closed");
    }.bind(this);

    socket.onmessage = function(message: any) {
      // if (this["debug"]) console.group("onmessage");

      // TODO - check if there is something else on the message that could be used/inspected?

      const event: ReceivedMessage = JSON.parse(message["data"]);

      switch (event.action) {
        case "message":
          new MessageProcessor(this, this.sender).handleMessage(event);
          break;
        case "ack":
          new MessageProcessor(this, this.sender).handleAck(event);
          break;
        default:
          this._unrecognizedMessage(event);
      }

      // if (this["debug"]) console.groupEnd();
    }.bind(this);
  };

  log(...args: any[]) {
    if (!this.silent) {
      console.log.apply(console, args);
    }
  };

  log_debug(...args: any[]) {
    if (this.debug) {
      console.log.apply(console, args);
    }
  };
}

export default catsocket;
