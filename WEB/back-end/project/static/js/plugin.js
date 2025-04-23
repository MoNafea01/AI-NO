document.addEventListener("DOMContentLoaded", function () {
    var socket = new WebSocket("ws://127.0.0.1:8000/ws/chat/");

    socket.onopen = function () {
        console.log("WebSocket connection established.");
    };

    socket.onmessage = function (event) {
        var data = JSON.parse(event.data);
        var messageCanvas = document.getElementById("messageCanvas");

        var messageElement = document.createElement("div");
        messageElement.classList.add("message");

        var currentUser = document.querySelector("input[name='username']").value;
        if (data.username === currentUser) {
            messageElement.classList.add("my-message");
        } else {
            messageElement.classList.add("other-message");
        }

        messageElement.innerHTML = `<strong>${data.username}:</strong> ${data.message}`;
        messageCanvas.appendChild(messageElement);

        messageCanvas.scrollTop = messageCanvas.scrollHeight;
    };

    document.getElementById("Chatform").addEventListener("submit", function (e) {
        e.preventDefault();
        var username = document.querySelector("input[name='username']").value;
        var usermsg = document.querySelector("input[name='usermsg']").value;

        var messageData = JSON.stringify({ 
            username: username, 
            message: usermsg  
        });

        socket.send(messageData);
        this.reset();
    });
});
