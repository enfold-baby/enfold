/* Galaxy of moons for enfold.baby.
   An endless seeded star field, supporter moons in planting order and the odd falling star.
   Interactive on /galaxy/, a slow drifting preview in the /support/ hero. */
(function () {
  "use strict";

  var ICON_URL = "https://api.enfold.baby/v1/support/icon/";
  var TIER_LABEL = { tea: "a warm bottle", nest: "an extra hour of sleep", moon: "a whole quiet night", wish: "a chosen amount" };
  var TINT = { tea: "#e9d9a8", nest: "#9fbfae", moon: "#d98ea0", wish: "#c9d3f0" };
  // Stars live in 1024-unit tiles generated from a fixed seed per tile, so the sky never
  // runs out and looks the same on every visit. Three depths give parallax.
  var TILE = 1024;
  var LAYERS = [
    { depth: 0.35, count: 46, rMin: 0.45, rMax: 0.9, aMin: 0.25, aMax: 0.55 },
    { depth: 0.65, count: 22, rMin: 0.6, rMax: 1.3, aMin: 0.4, aMax: 0.75 },
    { depth: 1, count: 10, rMin: 0.9, rMax: 1.9, aMin: 0.6, aMax: 1 }
  ];
  var GLOW = 34;

  function euro(c) { return "€" + Math.round(c / 100).toLocaleString("en-GB"); }
  function esc(s) { return String(s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
  function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
  function rng(seed) {
    return function () {
      seed = (seed + 0x6d2b79f5) | 0;
      var t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };
  }
  function hashString(s) { var h = 2166136261; for (var i = 0; i < s.length; i++) { h = Math.imul(h ^ s.charCodeAt(i), 16777619); } return h >>> 0; }
  function initials(name) { return name.trim().split(/\s+/).slice(0, 2).map(function (w) { return w[0]; }).join("").toUpperCase(); }
  function plantedKey(m) { return m.planted_at || (m.since ? m.since + "T23:59:59" : "9999"); }

  function mount(opts) {
    var canvas = opts.canvas, wrap = opts.wrap;
    var interactive = opts.interactive !== false;
    var card = opts.card || null, titleEl = opts.titleEl || null, hudEl = opts.hudEl || null;
    // Preview mode: where (in CSS pixels) the moon cluster should sit, and how big it may get.
    var previewFrame = opts.previewFrame || function (w, h) { return { cx: w / 2, cy: h / 2, radius: Math.min(w, h) / 2 }; };
    var reduceMotion = !!(window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches);
    var ctx = canvas.getContext("2d");
    var dpr = Math.min(window.devicePixelRatio || 1, 2);
    var W = 0, H = 0;
    var cam = { x: 0, y: 0, z: 1 };
    var vel = { x: 0, y: 0 };
    var MAX_ZOOM = 3;
    var minZoom = 0.25;
    var far = 0;
    var previewFar = 0; // the preview frames the first 40 moons, so a big sky never shrinks to specks
    var bound = 700; // how far (world units) the view centre may wander before easing back
    var moons = [];
    var selected = null;
    var flight = null;
    var running = true, dirty = true, rafId = 0, last = 0;
    var pointers = new Map();
    var drag = null, pinch = null, moved = false, lastMove = null, lastTap = null;
    var tiles = new Map();

    // Stars
    function tileStars(li, tx, ty) {
      var key = li + ":" + tx + ":" + ty;
      var list = tiles.get(key);
      if (list) return list;
      var L = LAYERS[li];
      var rand = rng(Math.imul(tx, 73856093) ^ Math.imul(ty, 19349663) ^ Math.imul(li + 1, 83492791));
      list = [];
      for (var i = 0; i < L.count; i++) {
        list.push({ x: (tx + rand()) * TILE, y: (ty + rand()) * TILE, r: L.rMin + rand() * (L.rMax - L.rMin), a: L.aMin + rand() * (L.aMax - L.aMin), tw: rand() * 6.283, warm: rand() < 0.12 });
      }
      if (tiles.size > 1500) tiles.clear();
      tiles.set(key, list);
      return list;
    }
    function drawStars(ts) {
      for (var li = 0; li < LAYERS.length; li++) {
        var L = LAYERS[li];
        var zp = 1 + (cam.z - 1) * L.depth;
        var ox = W / 2 + cam.x * L.depth, oy = H / 2 + cam.y * L.depth;
        var x0 = Math.floor(-ox / zp / TILE), x1 = Math.floor((W - ox) / zp / TILE);
        var y0 = Math.floor(-oy / zp / TILE), y1 = Math.floor((H - oy) / zp / TILE);
        if ((x1 - x0 + 1) * (y1 - y0 + 1) > 1200) continue;
        // When zoomed far out, thin the stars so the screen density stays calm.
        var n = Math.max(1, Math.round(L.count * Math.min(1, (zp / 0.5) * (zp / 0.5))));
        var size = Math.min(1.4, Math.sqrt(zp));
        for (var tx = x0; tx <= x1; tx++) {
          for (var ty = y0; ty <= y1; ty++) {
            var list = tileStars(li, tx, ty);
            for (var i = 0; i < n; i++) {
              var s = list[i];
              var sx = ox + s.x * zp, sy = oy + s.y * zp;
              if (sx < -4 || sy < -4 || sx > W + 4 || sy > H + 4) continue;
              ctx.globalAlpha = s.a * (reduceMotion ? 1 : 0.7 + 0.3 * Math.sin(ts / 900 + s.tw));
              ctx.fillStyle = s.warm ? "#f6e3c4" : "#faf7f2";
              ctx.beginPath(); ctx.arc(sx, sy, Math.max(0.35, s.r * size), 0, 6.283); ctx.fill();
            }
          }
        }
      }
      ctx.globalAlpha = 1;
    }
    function drawBackground() {
      var g = ctx.createLinearGradient(0, 0, 0, H);
      g.addColorStop(0, "#171d35"); g.addColorStop(1, "#0e1220");
      ctx.fillStyle = g; ctx.fillRect(0, 0, W, H);
      // A soft glow that belongs to the sky around the first moon, so it travels with you.
      var cx = W / 2 + cam.x, cy = H / 2 + cam.y;
      var rad = Math.max(260, bound * 0.9 * cam.z);
      var glow = ctx.createRadialGradient(cx, cy, 0, cx, cy, rad);
      glow.addColorStop(0, "rgba(96, 110, 180, 0.18)");
      glow.addColorStop(0.5, "rgba(74, 86, 146, 0.07)");
      glow.addColorStop(1, "rgba(74, 86, 146, 0)");
      ctx.fillStyle = glow; ctx.fillRect(0, 0, W, H);
    }

    // Falling stars: rare, quick, never with reduced motion.
    var meteors = [];
    var nextMeteor = performance.now() + 2500 + Math.random() * 3500;
    function spawnMeteor(now) {
      var fromLeft = Math.random() < 0.5;
      var angle = (18 + Math.random() * 26) * Math.PI / 180;
      var bright = Math.random() < 0.15;
      meteors.push({
        x: W * (fromLeft ? Math.random() * 0.6 : 0.4 + Math.random() * 0.6),
        y: H * Math.random() * 0.45,
        dx: (fromLeft ? 1 : -1) * Math.cos(angle), dy: Math.sin(angle),
        speed: bright ? 700 : 1000 + Math.random() * 500,
        len: bright ? 260 : 120 + Math.random() * 110,
        life: bright ? 1300 : 650 + Math.random() * 350,
        width: bright ? 2.2 : 1.4,
        born: now
      });
      nextMeteor = now + 4000 + Math.random() * 9000;
    }
    function drawMeteors(now) {
      if (reduceMotion) return;
      if (now >= nextMeteor) spawnMeteor(now);
      for (var i = meteors.length - 1; i >= 0; i--) {
        var m = meteors[i];
        var age = now - m.born;
        if (age > m.life) { meteors.splice(i, 1); continue; }
        var p = age / m.life;
        var fade = p < 0.15 ? p / 0.15 : 1 - (p - 0.15) / 0.85;
        var dist = m.speed * age / 1000;
        var hx = m.x + m.dx * dist, hy = m.y + m.dy * dist;
        var tail = Math.min(m.len, dist);
        var tx = hx - m.dx * tail, ty = hy - m.dy * tail;
        var g = ctx.createLinearGradient(tx, ty, hx, hy);
        g.addColorStop(0, "rgba(250, 247, 242, 0)");
        g.addColorStop(1, "rgba(250, 247, 242, " + (0.9 * fade).toFixed(3) + ")");
        ctx.strokeStyle = g; ctx.lineWidth = m.width; ctx.lineCap = "round";
        ctx.beginPath(); ctx.moveTo(tx, ty); ctx.lineTo(hx, hy); ctx.stroke();
        ctx.globalAlpha = fade; ctx.fillStyle = "#fffdf6";
        ctx.beginPath(); ctx.arc(hx, hy, m.width * 0.9, 0, 6.283); ctx.fill();
        ctx.globalAlpha = 1;
      }
    }
    function restartMeteors() { meteors = []; nextMeteor = performance.now() + 1500 + Math.random() * 3500; }
    document.addEventListener("visibilitychange", function () { if (!document.hidden) restartMeteors(); });

    // Moons: placed in planting order on a golden-angle spiral, so a moon never moves
    // once planted; new moons land on the outside and the sky grows with them.
    function layout(list) {
      var sorted = list.slice().sort(function (a, b) {
        var ka = plantedKey(a), kb = plantedKey(b);
        if (ka !== kb) return ka < kb ? -1 : 1;
        return a.id < b.id ? -1 : 1;
      });
      var max = 1;
      for (var k = 0; k < sorted.length; k++) max = Math.max(max, sorted[k].amount_cents);
      far = 0;
      previewFar = 0;
      var out = sorted.map(function (m, i) {
        var t = i * 2.39996;
        var d = i === 0 ? 0 : 150 + 165 * Math.sqrt(i);
        var r = 22 + 40 * Math.sqrt(m.amount_cents / max);
        far = Math.max(far, d + r);
        if (i < 40) previewFar = Math.max(previewFar, d + r);
        return { m: m, x: Math.cos(t) * d, y: Math.sin(t) * d, r: r, phase: (hashString(String(m.id)) % 628) / 100, sprite: null, spriteScale: 0, icon: null, iconState: m.has_icon ? "idle" : "none", sx: 0, sy: 0, visible: false };
      });
      bound = far + 420;
      return out;
    }
    // Sprites are rebuilt sharper as you zoom in (never above 1024px).
    function spriteScaleFor(o) { return Math.min(dpr * Math.max(1, cam.z) * 1.25, 1024 / Math.ceil((o.r + GLOW) * 2)); }
    function makeSprite(o) {
      var size = Math.ceil((o.r + GLOW) * 2);
      var scale = spriteScaleFor(o);
      var c = document.createElement("canvas");
      c.width = c.height = Math.ceil(size * scale);
      var g = c.getContext("2d");
      g.scale(scale, scale);
      var mid = size / 2, col = TINT[o.m.tier] || "#e9d9a8";
      g.shadowColor = col; g.shadowBlur = 30 * scale; // shadow blur ignores the transform
      var rg = g.createRadialGradient(mid - o.r * 0.35, mid - o.r * 0.35, o.r * 0.1, mid, mid, o.r);
      rg.addColorStop(0, "#fffdf6"); rg.addColorStop(0.6, col); rg.addColorStop(1, "#8b7a4f");
      g.fillStyle = rg; g.beginPath(); g.arc(mid, mid, o.r, 0, 6.283); g.fill();
      g.shadowBlur = 0;
      if (o.icon) {
        g.save(); g.beginPath(); g.arc(mid, mid, o.r * 0.55, 0, 6.283); g.clip();
        g.drawImage(o.icon, mid - o.r * 0.55, mid - o.r * 0.55, o.r * 1.1, o.r * 1.1);
        g.restore();
      } else {
        g.fillStyle = "#3d3229"; g.font = "800 " + Math.max(10, o.r * 0.6) + "px Nunito, system-ui, sans-serif";
        g.textAlign = "center"; g.textBaseline = "middle";
        g.fillText(initials(o.m.name), mid, mid + 1);
      }
      o.sprite = c;
      o.spriteScale = scale;
    }
    function loadIcon(o) {
      o.iconState = "loading";
      var img = new Image();
      img.onload = function () { o.icon = img; o.iconState = "ok"; o.sprite = null; dirty = true; };
      img.onerror = function () { o.iconState = "failed"; };
      img.src = ICON_URL + encodeURIComponent(o.m.id);
    }
    if (document.fonts && document.fonts.ready) {
      document.fonts.ready.then(function () { moons.forEach(function (o) { o.sprite = null; }); dirty = true; });
    }
    function drawMoons(ts) {
      var z = cam.z, ox = W / 2 + cam.x, oy = H / 2 + cam.y;
      ctx.font = "700 13px Nunito, system-ui, sans-serif";
      ctx.textAlign = "center"; ctx.textBaseline = "top";
      for (var i = 0; i < moons.length; i++) {
        var o = moons[i];
        var bob = reduceMotion ? 0 : Math.sin(ts / 1400 + o.phase) * 3;
        var half = (o.r + GLOW) * z;
        o.sx = ox + o.x * z; o.sy = oy + (o.y + bob) * z;
        o.visible = !(o.sx + half < 0 || o.sx - half > W || o.sy + half < 0 || o.sy - half > H + 24);
        // Icons load only when a moon comes within a screen of the view.
        if (o.iconState === "idle" && Math.abs(o.sx - W / 2) < W * 1.5 && Math.abs(o.sy - H / 2) < H * 1.5) loadIcon(o);
        if (!o.visible) continue;
        if (!o.sprite || spriteScaleFor(o) > o.spriteScale * 1.4) makeSprite(o);
        ctx.drawImage(o.sprite, o.sx - half, o.sy - half, half * 2, half * 2);
        if (o.r * z >= 12 || o === selected) {
          var name = o.m.name.length > 22 ? o.m.name.slice(0, 21) + "…" : o.m.name;
          ctx.fillStyle = "#f3ede4";
          ctx.fillText(name, o.sx, o.sy + o.r * z + 8);
        }
      }
    }

    // Camera
    function homeZoom() { return clamp(W < 600 ? 0.75 : 1, minZoom, MAX_ZOOM); }
    function viewCentre() { return { x: -cam.x / cam.z, y: -cam.y / cam.z }; }
    function zoomAt(px, py, z2) {
      z2 = clamp(z2, minZoom, MAX_ZOOM);
      var wx = (px - W / 2 - cam.x) / cam.z, wy = (py - H / 2 - cam.y) / cam.z;
      cam.z = z2;
      cam.x = px - W / 2 - wx * z2;
      cam.y = py - H / 2 - wy * z2;
    }
    // Past the outermost moon, dragging meets growing resistance (at most 600 units of stretch).
    function rubber(rawX, rawY) {
      var cx = -rawX / cam.z, cy = -rawY / cam.z, d = Math.hypot(cx, cy);
      if (d <= bound) return { x: rawX, y: rawY };
      var soft = bound + 600 * (1 - 1 / ((d - bound) / 600 + 1));
      var k = soft / d;
      return { x: -cx * k * cam.z, y: -cy * k * cam.z };
    }
    function settle() {
      var c = viewCentre(), d = Math.hypot(c.x, c.y);
      if (d <= bound) return;
      var k = bound / d;
      cam.x += (-c.x * k * cam.z - cam.x) * 0.12;
      cam.y += (-c.y * k * cam.z - cam.y) * 0.12;
    }
    function placePreview(ts) {
      var f = previewFrame(W, H);
      var dx = reduceMotion ? 0 : Math.sin(ts / 23000) * 36;
      var dy = reduceMotion ? 0 : Math.cos(ts / 31000) * 24;
      cam.z = clamp(f.radius / (previewFar + 60), 0.15, 1.1);
      cam.x = f.cx - W / 2 + dx;
      cam.y = f.cy - H / 2 + dy;
    }
    function flyHome() {
      vel.x = vel.y = 0;
      closeCard();
      flight = { from: { x: cam.x, y: cam.y, z: cam.z }, to: { x: 0, y: 0, z: homeZoom() }, start: performance.now(), dur: reduceMotion ? 1 : 700 };
    }
    function fitMinZoom() {
      if (!W || !H) return;
      minZoom = clamp(Math.min(W, H) / (2 * bound) * 0.9, 0.05, 0.25);
      if (interactive && cam.z < minZoom) cam.z = minZoom;
    }
    function resize() {
      var w = wrap.clientWidth, h = wrap.clientHeight;
      if (!w || !h) return;
      W = w; H = h;
      canvas.width = Math.round(W * dpr); canvas.height = Math.round(H * dpr);
      canvas.style.width = W + "px"; canvas.style.height = H + "px";
      fitMinZoom();
      dirty = true;
    }

    // Moon cards
    function showCard(o) {
      if (!card) return;
      selected = o;
      var m = o.m;
      card.innerHTML = "<strong>" + esc(m.name) + "</strong>" + euro(m.amount_cents) + " · " + TIER_LABEL[m.tier] + (m.since ? "<br><small>since " + esc(m.since) + "</small>" : "") + (m.link ? '<br><a href="' + esc(m.link) + '" rel="nofollow noopener" target="_blank">Visit ↗</a>' : "");
      card.hidden = false;
      positionCard();
    }
    function closeCard() { selected = null; if (card) card.hidden = true; }
    function positionCard() {
      if (!card || !selected || card.hidden) return;
      if (!selected.visible) { closeCard(); return; }
      var cw = card.offsetWidth, ch = card.offsetHeight, rr = selected.r * cam.z;
      // Keep the card clear of the title, the bottom bar and the moon itself.
      var top = titleEl ? titleEl.offsetTop + titleEl.offsetHeight + 8 : 8;
      var bottom = hudEl ? hudEl.offsetTop - 8 : H - 8;
      var x, y = selected.sy - ch / 2;
      if (selected.sx + rr + 12 + cw <= W - 8) x = selected.sx + rr + 12;
      else if (selected.sx - rr - 12 - cw >= 8) x = selected.sx - rr - 12 - cw;
      else {
        x = selected.sx - cw / 2;
        y = selected.sy + rr + 30;
        if (y + ch > bottom) y = selected.sy - rr - 12 - ch;
      }
      card.style.left = clamp(x, 8, Math.max(8, W - cw - 8)) + "px";
      card.style.top = clamp(y, top, Math.max(top, bottom - ch)) + "px";
    }
    function hit(px, py) {
      for (var i = moons.length - 1; i >= 0; i--) {
        var o = moons[i];
        if (!o.visible) continue;
        var rr = Math.max(o.r * cam.z, 22), dx = px - o.sx, dy = py - o.sy;
        if (dx * dx + dy * dy <= rr * rr) return o;
      }
      return null;
    }

    // Pointer: drag, flick, pinch, tap, double tap. Keyboard: arrows, +/-, Home, Escape.
    function pinchState() {
      var p = Array.from(pointers.values());
      return { d: Math.hypot(p[0].x - p[1].x, p[0].y - p[1].y) || 1, mx: (p[0].x + p[1].x) / 2, my: (p[0].y + p[1].y) / 2 };
    }
    function startDrag(x, y) {
      drag = { x: x, y: y, cx: cam.x, cy: cam.y };
      lastMove = { x: x, y: y, t: performance.now() };
    }
    function endPointer(e) {
      if (!pointers.has(e.pointerId)) return;
      pointers.delete(e.pointerId);
      if (pointers.size === 0) wrap.classList.remove("dragging");
      if (pinch) {
        if (pointers.size < 2) {
          pinch = null; vel.x = vel.y = 0;
          if (pointers.size === 1) { var p = pointers.values().next().value; startDrag(p.x, p.y); }
        }
        return;
      }
      if (drag && !moved && e.type === "pointerup") {
        vel.x = vel.y = 0;
        var rect = canvas.getBoundingClientRect();
        var px = e.clientX - rect.left, py = e.clientY - rect.top, o = hit(px, py), t = performance.now();
        if (o) { showCard(o); lastTap = null; }
        else if (lastTap && t - lastTap.t < 320 && Math.hypot(px - lastTap.x, py - lastTap.y) < 30) { flyHome(); lastTap = null; }
        else { closeCard(); lastTap = { x: px, y: py, t: t }; }
      } else if (!lastMove || performance.now() - lastMove.t > 80 || e.type !== "pointerup") {
        vel.x = vel.y = 0;
      }
      drag = null;
    }
    if (interactive) {
      wrap.addEventListener("pointerdown", function (e) {
        if (e.target.closest(".galaxy-card, .galaxy-hud a, .galaxy-hud button")) return;
        try { wrap.setPointerCapture(e.pointerId); } catch (err) { /* pointer already gone */ }
        pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
        flight = null; vel.x = vel.y = 0;
        if (pointers.size === 1) { moved = false; startDrag(e.clientX, e.clientY); wrap.classList.add("dragging"); }
        else if (pointers.size === 2) { pinch = pinchState(); drag = null; moved = true; }
      });
      wrap.addEventListener("pointermove", function (e) {
        if (!pointers.has(e.pointerId)) return;
        pointers.set(e.pointerId, { x: e.clientX, y: e.clientY });
        if (pinch && pointers.size >= 2) {
          var now = pinchState(), rect = canvas.getBoundingClientRect();
          cam.x += now.mx - pinch.mx; cam.y += now.my - pinch.my;
          zoomAt(now.mx - rect.left, now.my - rect.top, cam.z * now.d / pinch.d);
          pinch = now;
          return;
        }
        if (!drag) return;
        var dx = e.clientX - drag.x, dy = e.clientY - drag.y;
        if (Math.abs(dx) + Math.abs(dy) > 4) moved = true;
        var r = rubber(drag.cx + dx, drag.cy + dy);
        cam.x = r.x; cam.y = r.y;
        var t = performance.now(), dt = Math.max(1, t - lastMove.t);
        vel.x = (e.clientX - lastMove.x) / dt * 16; vel.y = (e.clientY - lastMove.y) / dt * 16;
        lastMove = { x: e.clientX, y: e.clientY, t: t };
      });
      wrap.addEventListener("pointerup", endPointer);
      wrap.addEventListener("pointercancel", endPointer);
      wrap.addEventListener("wheel", function (e) {
        e.preventDefault();
        flight = null;
        var rect = canvas.getBoundingClientRect();
        var dy = e.deltaMode === 1 ? e.deltaY * 16 : e.deltaY;
        zoomAt(e.clientX - rect.left, e.clientY - rect.top, cam.z * Math.exp(-dy * (e.ctrlKey ? 0.01 : 0.0015)));
      }, { passive: false });
      wrap.addEventListener("keydown", function (e) {
        if (e.target !== wrap) return;
        var step = 90;
        switch (e.key) {
          case "ArrowLeft": flight = null; cam.x += step; break;
          case "ArrowRight": flight = null; cam.x -= step; break;
          case "ArrowUp": flight = null; cam.y += step; break;
          case "ArrowDown": flight = null; cam.y -= step; break;
          case "+": case "=": flight = null; zoomAt(W / 2, H / 2, cam.z * 1.2); break;
          case "-": case "_": flight = null; zoomAt(W / 2, H / 2, cam.z / 1.2); break;
          case "Home": case "0": flyHome(); break;
          case "Escape": closeCard(); break;
          default: return;
        }
        e.preventDefault();
      });
    }

    function frame(ts) {
      rafId = 0;
      if (!running) return;
      var dt = last ? Math.min(64, ts - last) : 16;
      last = ts;
      if (!interactive) {
        if (W) placePreview(ts);
      } else if (flight) {
        var p = Math.min(1, (ts - flight.start) / flight.dur);
        var ease = p < 0.5 ? 2 * p * p : 1 - Math.pow(-2 * p + 2, 2) / 2;
        cam.x = flight.from.x + (flight.to.x - flight.from.x) * ease;
        cam.y = flight.from.y + (flight.to.y - flight.from.y) * ease;
        cam.z = flight.from.z + (flight.to.z - flight.from.z) * ease;
        if (p >= 1) flight = null;
      } else if (!drag && !pinch) {
        if (vel.x || vel.y) {
          cam.x += vel.x * dt / 16; cam.y += vel.y * dt / 16;
          var decay = Math.pow(0.92, dt / 16);
          vel.x *= decay; vel.y *= decay;
          var c = viewCentre();
          if (Math.hypot(c.x, c.y) > bound) { vel.x *= 0.7; vel.y *= 0.7; }
          if (Math.hypot(vel.x, vel.y) < 0.05) vel.x = vel.y = 0;
        }
        settle();
      }
      // A still preview (reduced motion) only redraws when something changed.
      if (W && (interactive || !reduceMotion || dirty)) {
        ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
        drawBackground();
        drawStars(ts);
        drawMeteors(ts);
        drawMoons(ts);
        dirty = false;
      }
      positionCard();
      schedule();
    }
    function schedule() { if (!rafId && running) rafId = requestAnimationFrame(frame); }

    if (window.ResizeObserver) new ResizeObserver(function () { resize(); }).observe(wrap);
    else window.addEventListener("resize", resize);
    // Nothing to draw while the sky is scrolled out of view.
    if (window.IntersectionObserver) {
      new IntersectionObserver(function (entries) {
        running = entries[entries.length - 1].isIntersecting;
        if (running) { last = 0; dirty = true; restartMeteors(); schedule(); }
      }).observe(wrap);
    }

    resize();
    if (interactive) cam.z = homeZoom();
    schedule();

    return {
      render: function (list) { moons = layout(list || []); fitMinZoom(); dirty = true; },
      flyHome: flyHome,
      ordered: function () { return moons.map(function (o) { return o.m; }); }
    };
  }

  window.EnfoldGalaxy = { mount: mount, euro: euro, esc: esc, rng: rng, tierLabel: TIER_LABEL };
})();
