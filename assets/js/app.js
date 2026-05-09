// Phoenix assets are imported from dependencies.
import topbar from "topbar";

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
let livePath = document.querySelector("meta[name='live-path']").getAttribute("content");
let liveTransport = document .querySelector("meta[name='live-transport']") .getAttribute("content");

// Theme management
const Theme = {
  STORAGE_KEY: "error-tracker-theme",

  init() {
    const saved = localStorage.getItem(this.STORAGE_KEY);
    if (saved === "light") {
      document.body.classList.add("light-theme");
    }
  },

  toggle() {
    const isLight = document.body.classList.toggle("light-theme");
    localStorage.setItem(this.STORAGE_KEY, isLight ? "light" : "dark");
  },

  isLight() {
    return document.body.classList.contains("light-theme");
  }
};

const Hooks = {
  JsonPrettyPrint: {
    mounted() {
      this.formatJson();
    },
    updated() {
      this.formatJson();
    },
    formatJson() {
      try {
        // Get the raw JSON content
        const rawJson = this.el.textContent.trim();
        // Parse and stringify with indentation
        const formattedJson = JSON.stringify(JSON.parse(rawJson), null, 2);
        // Update the element content
        this.el.textContent = formattedJson;
      } catch (error) {
        console.error("Error formatting JSON:", error);
        // Keep the original content if there's an error
      }
    }
  },
  ThemeInit: {
    mounted() {
      Theme.init();
    }
  }
};

let liveSocket = new LiveView.LiveSocket(livePath, Phoenix.Socket, {
  transport: liveTransport === "longpoll" ? Phoenix.LongPoll : WebSocket,
  params: { _csrf_token: csrfToken },
  hooks: Hooks

});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// Set up theme toggle via event delegation (CSP-compliant, avoids inline onclick)
document.addEventListener("click", function(e) {
  var toggle = e.target.closest("[data-theme-toggle]");
  if (toggle) {
    Theme.toggle();
  }
});

// connect if there are any LiveViews on the page
liveSocket.connect();
window.liveSocket = liveSocket;
