var guid = function guid() {
    var s4 = function () {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    };

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

var removeValue = function (arr, value) {
    var index = arr.indexOf(value);
    if (index !== -1) {
        arr.splice(index, 1);
    }
};

var catsocket = window["catsocket"] = {};
/** @define {boolean} */
var DEBUG_SERVER = true;

catsocket["init"] = function (api_key, options) {
    options = options || {};
    var user_id = options["user_id"];
    var host = options["host"];

    // TODO - asssert that API key exists
    user_id = user_id || guid();
    if (DEBUG_SERVER && !options["production"]) {
        host = host || "ws://localhost:9000";
    } else {
        host = host || "wss://catsocket.com";
    }

    var status_changed = options["status_changed"] || function() {};
    var cat = new CatSocket(api_key, user_id, host, status_changed);
    cat.connect();

    cat.log_debug("Trying to connect...");

    return cat;
};

/** @constructor */
function CatSocket(api_key, user_id, host, status_changed) {
    this["silent"] = false;
    this["debug"] = false;

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
    this["status_changed"] = status_changed;

    this._startTimer();

    return this;
}

/** @type {function(...*)} */
CatSocket.prototype.log = function () {
    if (!this["silent"]) {
        console.log.apply(console, arguments);
    }
};

/** @type {function(...*)} */
CatSocket.prototype.log_debug = function () {
    if (this["debug"]) {
        console.log.apply(console, arguments);
    }
};

CatSocket.prototype.connect = function () {
    // Close the previous connection if there was one
    if (this.socket) {
        this.socket.close();
    }

    this.is_identified = false;
    this.is_connected = false;

    this["status_changed"]("connecting");
    var url = this.host + "/b/ws";
    var socket = this.socket = new WebSocket(url);
    this._setHandlers(socket);
};

CatSocket.prototype._setHandlers = function (socket) {
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

    socket.onmessage = function (message) {
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

CatSocket.prototype.send = function (action, data) {
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

CatSocket.prototype._doSend = function (params) {
    if (this.is_connected && (this.is_identified || params["action"] == "identify")) {
        this.log_debug("->", params);
        this.sent_messages[params["id"]] = params;

        this.socket.send(JSON.stringify(params));
    } else {
        this.log_debug("Pushing to queue", params);
        this.queue.push(params);
    }
};

CatSocket.prototype.flushQueue = function () {
    this.log_debug("flushing queue");

    while (this.queue.length) {
        var item = this.queue.pop();
        this._doSend(item);
    }
};

CatSocket.prototype._handleMessage = function (event) {
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

CatSocket.prototype._handleAck = function (event) {
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

CatSocket.prototype._unrecognizedMessage = function (event) {
    console.error("Unrecognized message type", event["action"], "with data", event);
};

CatSocket.prototype._joinRooms = function () {
    for (var i = 0; i < this.joined_rooms.length; i++) {
        var room = this.joined_rooms[i];
        // We're sending here explicitly to avoid adding the same room to `this.joined_rooms` again.
        this.log_debug("TODO - fix re-joining", room);
        // this.send("join", {"room": room});
    }
};

CatSocket.prototype["join"] = function (room, handler, last_timestamp) {
    if (handler) {
        this.handlers[room] = handler;
    }

    this.joined_rooms.push(room);

    this.send("join", {
        "room": room,
        "last_timestamp": last_timestamp
    });
};

CatSocket.prototype["leave"] = function (room) {
    removeValue(this.joined_rooms, room);
    delete this.handlers[room];
    this.send("leave", {"room": room});
};

CatSocket.prototype["broadcast"] = function (room, message) {
    this.send("broadcast", {"room": room, "message": message});
};

CatSocket.prototype["close"] = function () {
    this.force_close = true;
    this.is_connected = false;
    this.is_identified = false;
    this.socket.close();

    this.log_debug("Socket closed...");
};

CatSocket.prototype._startTimer = function () {
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

export default catsocket;
