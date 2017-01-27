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
import React from "react";
import ReactDOM from 'react-dom';
import $ from 'jquery';
import catsocket from './client';

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

(function() {
  var ROOM = "chat";

  function randomText() {
    return Math.random().toString(36).substring(7);
  }

  // var Message = React.createClass({
  //   propTypes: {
  //     author: React.PropTypes.string.isRequired,
  //     text: React.PropTypes.string.isRequired
  //   },
  //
  //   render: function () {
  //     var classes = ["message even", "message"];
  //
  //     return (
  //       <div className={classes[this.props.even]}>
  //       <span className="author">{this.props.author}</span>
  //       <span className="text">{this.props.text}</span>
  //       </div>
  //     );
  //   }
  // });

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

  // var ChatMessages = React.createClass({
  //   render: function () {
  //
  //     var pics = this.props.messages.map(function (message, i) {
  //       return <Message key={i} author={message.author} even={i % 2} text={message.text}/>;
  //     });
  //
  //     return <div className="messages">{pics}</div>;
  //   }
  // });

  var ChatForm = React.createClass({
    handleSubmit: function (e) {
      e.preventDefault();
      var node = React.findDOMNode(this.refs.message);
      var msg = node.value.trim();

      if (msg) {
        node.value = "";
        this.props.cat.broadcast(ROOM, JSON.stringify({
          text: msg,
          author: this.props.username
        }));
      }
    },

    render: function () {
      var placeholder = "Talk as " + this.props.username + "...";
      return (
        <form onSubmit={this.handleSubmit}>
        <input className="form-control" type="text" placeholder={placeholder} ref="message" autoFocus="true" />
        </form>
      );
    }
  });

  var ChatBox = React.createClass({
    getInitialState: function () {
      return {messages: this.props.messages};
    },

    componentDidMount: function () {
      this.props.cat.join(ROOM, function (message) {
        var data = JSON.parse(message);

        this.setState(function (old) {
          var arr = old.messages;
          if (arr.length > 4) {
            arr.splice(0, 1);
          }
          arr.push(data);
          return {messages: arr};
        });
      }.bind(this));
    },

    render: function () {
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
  });

  var Chat = React.createClass({
    getInitialState: function () {
      var cat = catsocket.init("b766496f-34b0-4967-8c14-7534dc57d38d", {
        production: true
      });

      return {
        status: "connecting",
        cat: cat,
        username: this.props.username,
        messages: [
          {author: "Jack", text: "Kate ..."},
          {author: "Jack", text: "We have to go back!"}
        ]
      };
    },

    componentDidMount: function() {
      this.state.cat.status_changed = this.statusChanged;
    },

    statusChanged: function(value) {
      this.setState({status: value});
    },

    nameSelected: function (name) {
      this.setState({username: name});
    },

    render: function () {
      return <ChatBox status={this.state.status}
      cat={this.state.cat}
      room={this.state.room}
      username={this.state.username}
      messages={this.state.messages}/>;
    }
  });

  window.mountChat = function(username, element) {
    ReactDOM.render(React.createElement(Chat, {username: username}), element);
  };

  var buildPainter = function buildPainter(ctx) {
    return function paintAt(x, y) {
      ctx.beginPath();
      ctx.moveTo(x, y);
      ctx.lineTo(x-1, y-1);
      ctx.stroke();
    };
  }

  window.mountPaint = function mountPaint(canvas) {
    var ctx = canvas.getContext('2d');

    var mouse = {x: 0, y: 0};

    var paintAt = buildPainter(ctx);

    var ROOM = "painter"
    var cat = catsocket.init("b766496f-34b0-4967-8c14-7534dc57d38d", { production: true });

    cat.join(ROOM, function(msg) {
      paintAt(msg.x, msg.y);
    });

    canvas.addEventListener("mousemove", function(e) {
      var offset = $(this).parent().offset();

      mouse.x = e.pageX - offset.left - 15;
      mouse.y = e.pageY - offset.top;
    }, false);

    /* Drawing on Paint App */
    ctx.lineWidth = 3;
    ctx.lineJoin = "round";
    ctx.lineCap = "round";
    ctx.strokeStyle = "blue";

    canvas.addEventListener("mousemove", function(e) {
      cat.broadcast(ROOM, { x: mouse.x, y: mouse.y });
      paintAt(mouse.x, mouse.y);
    }, false);

  };
})();
