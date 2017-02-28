// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";
import * as React from "react";
import * as ReactDOM from "react-dom";
import * as $ from 'jquery';
import '../css/app.scss'
import catsocket from 'client/client';

const PRODUCTION_BACKEND = process.env.NODE_ENV === "production";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

//import socket from "./socket"

console.log('from app.tsx');

var ROOM = "chat";

function randomText() {
  return Math.random().toString(36).substring(7);
}

const classes = ["message even", "message"];
const Message = ({even, author, text}) =>
  <div className={classes[even]}>
    <span className="author">{author}</span>
    <span className="text">{text}</span>
  </div>;


const ChatMessages = ({messages}) =>
  <div className="messages">
    {messages.map((message, i) =>
      <Message key={i} author={message.author} even={i % 2} text={message.text}/>
    )}
  </div>;

class ChatForm extends React.Component<any, any> {
  public input: HTMLInputElement;

  handleSubmit(e) {
    e.preventDefault();
    var node = this.input;
    var msg = node.value.trim();

    if (msg) {
      node.value = "";
      this.props.cat.broadcast(ROOM, {
        text: msg,
        author: this.props.username
      });
    }
  }

  render() {
    var placeholder = "Talk as " + this.props.username + "...";
    return (
      <form onSubmit={this.handleSubmit.bind(this)}>
        <input className="form-control" type="text" placeholder={placeholder} ref={input => this.input = input} autoFocus={true} />
      </form>
    );
  }
}

class ChatBox extends React.Component<any, any> {
  constructor(props) {
    super(props);
    this.state = { messages: props.messages };
  }

  componentDidMount() {
    const self = this;
    this.props.cat.join(ROOM, function(data) {
      self.setState(function (old) {
        var arr = old.messages;
        if (arr.length > 4) {
          arr.splice(0, 1);
        }
        arr.push(data);
        return {messages: arr};
      });

    }.bind(this));
  }

  render() {
    var color, text;

    switch (this.props.status) {
      case "connecting":
        color = "label-primary";
        text = "Connecting";
        break;

      case "connected":
        color = "label-warning";
        text = "Authenticating";
        break;

      case "identified":
        color = "label-success";
        text = "Ready";
        break;

      case "closed":
        color = "label-danger";
        text = "Disconnected";
        break;

      default:
        console.warn("Unrecognized connection status", this.props.status);

    };

    var className = "pull-right label " + color;

    return (
      <div className="chat-inner">
      <span className={className}>{text}</span>
      <ChatMessages messages={this.state.messages}/>
      <ChatForm cat={this.props.cat} username={this.props.username}/>
      </div>
    );
  }
}

class Chat extends React.Component<any, any> {
  constructor(props) {
    super(props);

    var cat = catsocket.init("b766496f-34b0-4967-8c14-7534dc57d38d", {
      production: PRODUCTION_BACKEND
    });

    this.state = {
      status: "connecting",
      cat: cat,
      username: this.props.username,
      messages: [
        {author: "Jack", text: "Kate ..."},
        {author: "Jack", text: "We have to go back!"}
      ]
    };
  }

  componentDidMount() {
    this.state.cat.status_changed = this.statusChanged.bind(this);
  }

  statusChanged(value) {
    this.setState({status: value});
  }

  nameSelected(name) {
    this.setState({username: name});
  }

  render() {
    return <ChatBox status={this.state.status}
      cat={this.state.cat}
      room={this.state.room}
      username={this.state.username}
      messages={this.state.messages}/>;
  }
}


const mountChat = function(username, element) {
  ReactDOM.render(React.createElement(Chat, {username: username}), element);
};


// NEW PHOENIX BASED CLIENT //
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()

let channel = socket.channel("room:lobby", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })
// END //

var buildPainter = function buildPainter(ctx) {
  return function paintAt(x, y) {
    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x-1, y-1);
    ctx.stroke();
  };
}

const mountPaint = function mountPaint(canvas) {
  var ctx = canvas.getContext('2d');

  var paintAt = buildPainter(ctx);

  /* Drawing on Paint App */
  ctx.lineWidth = 3;
  ctx.lineJoin = "round";
  ctx.lineCap = "round";
  ctx.strokeStyle = "blue";

  canvas.addEventListener("mousemove", function(e: MouseEvent) {
    const x = e.offsetX;
    const y = e.offsetY;

    channel.push("new_msg", {body: {x: x, y: y})
    paintAt(x, y);
  }, false);

  channel.on("new_msg", payload => {
    const x = payload.body.x;
    const y = payload.body.y;
    paintAt(x, y);
  })

};

document.addEventListener("DOMContentLoaded", () => {
  mountChat("Jack", document.getElementById("home-chat-left"));
  mountChat("Kate", document.getElementById("home-chat-right"));
})

document.addEventListener("DOMContentLoaded", () => {
  mountPaint(document.querySelector(".painter-first"));
  mountPaint(document.querySelector(".painter-second"));
})
