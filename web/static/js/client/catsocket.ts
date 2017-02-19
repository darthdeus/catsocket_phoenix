import { guid, user } from 'client/helpers';
import Protocol from 'client/protocol';

/** @constructor */
class CatSocket {
  public socket:WebSocket;
  public user_id: any;
  public api_key: any;
  public handlers: any;
  public sent_messages: {};
  public protocol: Protocol;
  public queue: any[];
  public status_changed: any;

  public socketState: SocketState;

  public _timer_interval: number;

  constructor(api_key: string, user_id: string) {
    if (!api_key) { throw new Error("API key is required."); }

    this.socket = null;

    this.setSocketState("init");
    this.user_id = user_id;
    this.api_key = api_key;
    // room<->handler mapping for received messages
    this.handlers = {};
    this.sent_messages = {};
    this.queue = [];

    this.protocol = new Protocol();
  }

  storeAndSend(action: ClientAction, msgId: string, buffer: ArrayBuffer) {
    this.sent_messages[msgId] = { action: action };

    const isIdentified   = this.socketState == "identified";
    const shouldIdentify = this.socketState == "connected" && action == "identify";

    if (isIdentified || shouldIdentify) {
      this.socket.send(buffer);
    } else {
      this.queue.push(buffer);
    }
  };

  setSocketState(newState) {
    this.socketState = newState;

    if (typeof this.status_changed === "function") {
      this.status_changed(this.socketState);
    }
  }

  close() {
    this.socket.close();
    this.setSocketState("disconnected");
  };

  join(room: string, handler: any, last_timestamp?: number) {
    if (handler) {
      this.handlers[room] = handler;
    }

    const msgId = guid();
    const payload = this.protocol.join(msgId, room);
    this.storeAndSend("join", msgId, payload);
  };

  leave(room: string) {
    delete this.handlers[room];

    const msgId = guid();
    const payload = this.protocol.leave(msgId, room);
    this.storeAndSend("leave", msgId, payload);
  };

  identify() {
    const msgId = guid();
    const payload = this.protocol.identify(msgId, this.api_key, this.user_id);
    this.storeAndSend("identify", msgId, payload);
  }

  broadcast(room: string, data: any) {
    const msgId = guid();
    const payload = this.protocol.broadcast(msgId, room, data);
    this.storeAndSend("broadcast", msgId, payload);
  }

  connect(host) {
    // Close the previous connection if there was one
    if (this.socket) {
      this.socket.close();
    }

    const url = host + "/b/ws";
    this.socket = new WebSocket(url);
    this.socket.binaryType = "arraybuffer";
    this._setHandlers(this.socket);
  };

  _setHandlers(socket: WebSocket) {

    socket.onopen = () => {
      this.setSocketState("connected");
      this.identify();
    };

    socket.onclose = () => {
      console.error("Socket was disconnected");

      this.setSocketState("disconnected");
    };

    socket.onmessage = (message: any) => {
      if (typeof message.data !== "object") {
        console.error(`Invalid message type ${typeof message.data}, all communication now happens over binary`, message.data);
      } else {
        const parsed = this.protocol.parse(message.data);

        switch (parsed.action) {
          case "ack":
            const sent_message = this.sent_messages[parsed.id];
            if (sent_message) {
              if (sent_message.action === "identify") {
                this.setSocketState("identified");

                const q = this.queue;
                this.queue = [];

                for (let i = 0; i < q.length; ++i) {
                  this.socket.send(q[i]);
                }
              }

              delete this.sent_messages[parsed.id];
            } else {
              console.error("Received ACK for message which wasn't sent", parsed.id, parsed);
            }

            break;
          case "broadcast":

            break;
          default:
            console.error(`Invalid action ${parsed.action} received`, parsed);
            break;
        }
      }

      // // TODO - rozlisovat kontrolnim kodem
      // if (typeof message.data === "string") {
      //   const event: ReceivedMessage = JSON.parse(message.data);
      //
      //   if (event.room && event.message) {
      //     const handler = this.handlers[event.room];
      //     handler.call(null, event.message);
      //
      //   } else {
      //     console.error("Unrecognized message", event);
      //   }
      //
      // } else {
      //   let guid = "";
      //   const view = new DataView(message.data);
      // }
    };
  };
}

export default CatSocket;
