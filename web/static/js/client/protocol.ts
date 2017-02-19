const ROOM_MAX_LEN = 16;

const IDENTIFY  = 0;
const JOIN      = 1;
const LEAVE     = 2;
const BROADCAST = 3;

const CODE_LEN = 1;

const GUID_LEN = 36;

class Protocol {
  writeASCIIString(view: DataView, offset: number, str: string) {
    for (let i = 0; i < str.length; ++i) {
      view.setUint8(offset + i, str.charCodeAt(i));
    }
  }

  identify(msgId: string, apiKey: string, userGuid: string): ArrayBuffer {
    let buffer = new ArrayBuffer(CODE_LEN + 3*GUID_LEN);
    let view   = new DataView(buffer);

    view.setUint8(0, IDENTIFY);

    this.writeASCIIString(view, CODE_LEN, msgId);
    this.writeASCIIString(view, CODE_LEN + 1*GUID_LEN, apiKey);
    this.writeASCIIString(view, CODE_LEN + 2*GUID_LEN, userGuid);

    return buffer;
  }

  join(msgId: string, room: string): ArrayBuffer {
    let buffer = new ArrayBuffer(CODE_LEN + GUID_LEN + ROOM_MAX_LEN);
    let view   = new DataView(buffer);

    const paddedRoom = this.padRoom(room);

    view.setUint8(0, JOIN);
    this.writeASCIIString(view, CODE_LEN, msgId);
    this.writeASCIIString(view, CODE_LEN + GUID_LEN, paddedRoom);

    return buffer;
  }

  leave(msgId: string, room: string): ArrayBuffer {
    let buffer = new ArrayBuffer(CODE_LEN + GUID_LEN + ROOM_MAX_LEN);
    let view   = new DataView(buffer);

    const paddedRoom = this.padRoom(room);

    view.setUint8(0, LEAVE);
    this.writeASCIIString(view, CODE_LEN, msgId);
    this.writeASCIIString(view, CODE_LEN + GUID_LEN, paddedRoom);

    return buffer;
  }

  broadcast(msgId: string, room: string, message: any): ArrayBuffer {
    const payload = JSON.stringify(message);

    // TODO - check no utf-8?
    // TODO - check max message length

    let buffer = new ArrayBuffer(CODE_LEN + GUID_LEN + ROOM_MAX_LEN + payload.length);
    let view = new DataView(buffer);

    const paddedRoom = this.padRoom(room);

    view.setUint8(0, BROADCAST);

    this.writeASCIIString(view, CODE_LEN, msgId);
    this.writeASCIIString(view, CODE_LEN + GUID_LEN, paddedRoom);
    this.writeASCIIString(view, CODE_LEN + GUID_LEN + ROOM_MAX_LEN, payload);

    return buffer;
  };

  padRoom(roomName: string) {
    if (roomName.length > ROOM_MAX_LEN) {
      throw `Room name must be at most ${ROOM_MAX_LEN} characters`;
    }

    const padding = "0000000000000000";
    const paddedRoom = (padding + roomName).slice(-ROOM_MAX_LEN);

    return paddedRoom;
  }

}


export default Protocol;
