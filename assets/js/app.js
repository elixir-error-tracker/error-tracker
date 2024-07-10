// Establish Phoenix Socket and LiveView configuration.
import { Socket, LongPoll } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "topbar";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let socketPath = document.querySelector("meta[name='socket-path']").getAttribute("content");
let socketTransport = document.querySelector("meta[name='socket-transport']").getAttribute("content");
let normalizedTransport = (socketTransport == "longpoll") ? LongPoll : WebSocket;

let liveSocket = new LiveSocket(socketPath, Socket, { transport: normalizedTransport, params: { _csrf_token: csrfToken }});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();
window.liveSocket = liveSocket;
