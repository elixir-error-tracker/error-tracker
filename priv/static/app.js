var __create = Object.create;
var __getProtoOf = Object.getPrototypeOf;
var __defProp = Object.defineProperty;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __toESM = (mod, isNodeMode, target) => {
  target = mod != null ? __create(__getProtoOf(mod)) : {};
  const to = isNodeMode || !mod || !mod.__esModule ? __defProp(target, "default", { value: mod, enumerable: true }) : target;
  for (let key of __getOwnPropNames(mod))
    if (!__hasOwnProp.call(to, key))
      __defProp(to, key, {
        get: () => mod[key],
        enumerable: true
      });
  return to;
};
var __commonJS = (cb, mod) => () => (mod || cb((mod = { exports: {} }).exports, mod), mod.exports);

// ../node_modules/topbar/topbar.min.js
var require_topbar_min = __commonJS((exports, module) => {
  (function(window2, document2) {
    function repaint() {
      canvas.width = window2.innerWidth, canvas.height = 5 * options.barThickness;
      var ctx = canvas.getContext("2d");
      ctx.shadowBlur = options.shadowBlur, ctx.shadowColor = options.shadowColor;
      var stop, lineGradient = ctx.createLinearGradient(0, 0, canvas.width, 0);
      for (stop in options.barColors)
        lineGradient.addColorStop(stop, options.barColors[stop]);
      ctx.lineWidth = options.barThickness, ctx.beginPath(), ctx.moveTo(0, options.barThickness / 2), ctx.lineTo(Math.ceil(currentProgress * canvas.width), options.barThickness / 2), ctx.strokeStyle = lineGradient, ctx.stroke();
    }
    var canvas, currentProgress, showing, progressTimerId = null, fadeTimerId = null, delayTimerId = null, options = { autoRun: true, barThickness: 3, barColors: { 0: "rgba(26,  188, 156, .9)", ".25": "rgba(52,  152, 219, .9)", ".50": "rgba(241, 196, 15,  .9)", ".75": "rgba(230, 126, 34,  .9)", "1.0": "rgba(211, 84,  0,   .9)" }, shadowBlur: 10, shadowColor: "rgba(0,   0,   0,   .6)", className: null }, topbar = { config: function(opts) {
      for (var key in opts)
        options.hasOwnProperty(key) && (options[key] = opts[key]);
    }, show: function(handler) {
      var type, elem;
      showing || (handler ? delayTimerId = delayTimerId || setTimeout(() => topbar.show(), handler) : (showing = true, fadeTimerId !== null && window2.cancelAnimationFrame(fadeTimerId), canvas || ((elem = (canvas = document2.createElement("canvas")).style).position = "fixed", elem.top = elem.left = elem.right = elem.margin = elem.padding = 0, elem.zIndex = 100001, elem.display = "none", options.className && canvas.classList.add(options.className), type = "resize", handler = repaint, (elem = window2).addEventListener ? elem.addEventListener(type, handler, false) : elem.attachEvent ? elem.attachEvent("on" + type, handler) : elem["on" + type] = handler), canvas.parentElement || document2.body.appendChild(canvas), canvas.style.opacity = 1, canvas.style.display = "block", topbar.progress(0), options.autoRun && function loop() {
        progressTimerId = window2.requestAnimationFrame(loop), topbar.progress("+" + 0.05 * Math.pow(1 - Math.sqrt(currentProgress), 2));
      }()));
    }, progress: function(to) {
      return to === undefined || (typeof to == "string" && (to = (0 <= to.indexOf("+") || 0 <= to.indexOf("-") ? currentProgress : 0) + parseFloat(to)), currentProgress = 1 < to ? 1 : to, repaint()), currentProgress;
    }, hide: function() {
      clearTimeout(delayTimerId), delayTimerId = null, showing && (showing = false, progressTimerId != null && (window2.cancelAnimationFrame(progressTimerId), progressTimerId = null), function loop() {
        return 1 <= topbar.progress("+.1") && (canvas.style.opacity -= 0.05, canvas.style.opacity <= 0.05) ? (canvas.style.display = "none", void (fadeTimerId = null)) : void (fadeTimerId = window2.requestAnimationFrame(loop));
      }());
    } };
    typeof module == "object" && typeof module.exports == "object" ? module.exports = topbar : typeof define == "function" && define.amd ? define(function() {
      return topbar;
    }) : this.topbar = topbar;
  }).call(exports, window, document);
});

// app.js
var import_topbar = __toESM(require_topbar_min(), 1);
var csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
var livePath = document.querySelector("meta[name='live-path']").getAttribute("content");
var liveTransport = document.querySelector("meta[name='live-transport']").getAttribute("content");
var Theme = {
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
var Hooks = {
  JsonPrettyPrint: {
    mounted() {
      this.formatJson();
    },
    updated() {
      this.formatJson();
    },
    formatJson() {
      try {
        const rawJson = this.el.textContent.trim();
        const formattedJson = JSON.stringify(JSON.parse(rawJson), null, 2);
        this.el.textContent = formattedJson;
      } catch (error) {
        console.error("Error formatting JSON:", error);
      }
    }
  },
  ThemeInit: {
    mounted() {
      Theme.init();
    }
  },
  CopyToClipboard: {
    mounted() {
      this.label = this.el.dataset.copyLabel || this.el.textContent;
      this.copiedLabel = this.el.dataset.copiedLabel || "Copied";
      this.timeout = null;
      this.onClick = () => this.copy();
      this.el.addEventListener("click", this.onClick);
    },
    destroyed() {
      this.el.removeEventListener("click", this.onClick);
      clearTimeout(this.timeout);
    },
    copy() {
      const target = document.getElementById(this.el.dataset.copyTarget);
      if (!target)
        return;
      const text = target.value || target.textContent;
      if (!text)
        return;
      const writeText = navigator.clipboard ? navigator.clipboard.writeText(text).catch(() => this.writeTextFallback(target)) : this.writeTextFallback(target);
      writeText.then(() => {
        this.el.textContent = this.copiedLabel;
        clearTimeout(this.timeout);
        this.timeout = setTimeout(() => {
          this.el.textContent = this.label;
        }, 2000);
      });
    },
    writeTextFallback(target) {
      target.select();
      document.execCommand("copy");
      target.blur();
      return Promise.resolve();
    }
  }
};
var liveSocket = new LiveView.LiveSocket(livePath, Phoenix.Socket, {
  transport: liveTransport === "longpoll" ? Phoenix.LongPoll : WebSocket,
  params: { _csrf_token: csrfToken },
  hooks: Hooks
});
import_topbar.default.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => import_topbar.default.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => import_topbar.default.hide());
document.addEventListener("click", function(e) {
  var toggle = e.target.closest("[data-theme-toggle]");
  if (toggle) {
    Theme.toggle();
  }
});
liveSocket.connect();
window.liveSocket = liveSocket;
