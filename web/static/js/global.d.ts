interface MessageHandler {
  (message: ReceivedMessage): void;
}

interface CatsocketOptions {
  user_id?: string;
  host?: string;
  production?: boolean;
}

type ClientAction = "join" | "leave" | "broadcast" | "identify";
interface ClientMessage {
  id: string;
  action: ClientAction;
}

interface ReceivedMessage {
  room: string;
  message: any;
}

type Status = "connecting" | "connected" | "identified";

type SocketState = "init" | "connected" | "identified" | "disconnected";
