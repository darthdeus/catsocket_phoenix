import { guid, user } from 'client/helpers';
import Protocol from 'client/protocol';

/** @constructor */
class CatSocket {
  public socket:WebSocket;
  public user_id: any;
  public api_key: any;
  public handlers: any;
  public sent_messages: any;
  public protocol: Protocol;

  public socketState: SocketState;

  public _timer_interval: number;

  constructor(api_key: string, user_id: string) {
    if (!api_key) { throw new Error("API key is required."); }

    this.socket = null;

    this.socketState = "init";
    this.user_id = user_id;
    this.api_key = api_key;
    // room<->handler mapping for received messages
    this.handlers = {};
    this.sent_messages = [];

    this.protocol = new Protocol();
  }

  // send(action: ClientAction, data: any) {
  //   let params = {
  //     "id": guid(),
  //     "action": action,
  //     "data": data,
  //   };
  //
  //   if (action == "identify") {
  //     params["user"] = this.user_id;
  //     params["api_key"] = this.api_key;
  //   }
  //
  //   this._doSend(params);
  // };

  storeAndSend(buffer: ArrayBuffer) {
    this.socket.send(buffer);
    // if (this.socketState == "identified" || params.action == "identify") {
    //   this.socket.send(JSON.stringify(params));
    // } else {
    //   console.error("Sending a message before the client is connected");
    // }
  };

  close() {
    this.socket.close();
    this.socketState = "disconnected";
  };

  leave(room: string) {
    delete this.handlers[room];

    const payload = this.protocol.leave(guid(), room);
    this.storeAndSend(payload);
  };

  join(room: string, handler: any, last_timestamp?: number) {
    if (handler) {
      this.handlers[room] = handler;
    }

    const payload = this.protocol.join(guid(), room);
    this.storeAndSend(payload);
  };

  identify() {
    const payload = this.protocol.identify(guid(), this.api_key, this.user_id);
    this.storeAndSend(payload);
  }

  broadcast(room: string, data: any) {
    const payload = this.protocol.broadcast(guid(), room, data);
    this.storeAndSend(payload);
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
      this.socketState = "connected";
      this.identify();
    };

    socket.onclose = () => {
      console.error("Socket was disconnected");

      this.socketState = "disconnected";
    };

    socket.onmessage = (message: any) => {
      // TODO - rozlisovat kontrolnim kodem
      if (typeof message.data === "string") {
        const event: ReceivedMessage = JSON.parse(message.data);

        if (event.room && event.message) {
          const handler = this.handlers[event.room];
          handler.call(null, event.message);

        } else {
          console.error("Unrecognized message", event);
        }

      } else {
        let guid = "";
        const view = new DataView(message.data);

        for (let i = 0; i < message.data.byteLength; i++) {
          guid += String.fromCharCode(view.getUint8(i));
        }

        const sent_message = this.sent_messages[guid];

        if (sent_message) {
          if (sent_message["action"] === "identify") {
            this.socketState = "identified";
          }

          delete this.sent_messages[guid];
        } else {
          console.error("Received ACK for message which wasn't sent", guid, event);
        }
      }
    };
  };
}

export default CatSocket;
