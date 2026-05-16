function Pandoc(doc)
  if not string.match(FORMAT, "revealjs") then
    return doc
  end

  local script = [[
<script>
(function () {
  var css = [
    "#revealjs-html-link {",
    "  position: fixed;",
    "  top: 8px;",
    "  right: 8px;",
    "  z-index: 31;",
    "  font-size: 0.55em;",
    "  line-height: 1;",
    "}",
    "#revealjs-html-link a {",
    "  color: rgba(0, 0, 0, 0.5);",
    "  text-decoration: none;",
    "  border: 1px solid rgba(0, 0, 0, 0.2);",
    "  padding: 4px 8px;",
    "  border-radius: 4px;",
    "  background: rgba(255, 255, 255, 0.8);",
    "  transition: color 0.15s, background 0.15s;",
    "}",
    "#revealjs-html-link a:hover {",
    "  color: rgba(0, 0, 0, 0.9);",
    "  background: rgba(255, 255, 255, 0.98);",
    "  border-color: rgba(0, 0, 0, 0.4);",
    "}"
  ].join("\n");

  function getHtmlBase() {
    var url = window.location.href.split("#")[0];
    return url.replace(/-slides\.html$/, ".html");
  }

  function getCurrentSectionId() {
    if (typeof Reveal === "undefined" || !Reveal.getCurrentSlide) {
      return null;
    }
    var slide = Reveal.getCurrentSlide();
    if (!slide) {
      return null;
    }
    // If the current slide itself has an id, use it
    if (slide.id) {
      return slide.id;
    }
    // Walk backwards through sibling sections to find the nearest one with an id
    var sibling = slide.previousElementSibling;
    while (sibling) {
      if (sibling.tagName === "SECTION" && sibling.id) {
        return sibling.id;
      }
      sibling = sibling.previousElementSibling;
    }
    // Fall back to the first section[id] inside the parent container
    var parent = slide.parentElement;
    if (parent && parent.tagName === "SECTION") {
      var firstNamed = parent.querySelector("section[id]");
      if (firstNamed) {
        return firstNamed.id;
      }
    }
    return null;
  }

  function updateHtmlLink() {
    var anchor = document.getElementById("revealjs-html-anchor");
    if (!anchor) {
      return;
    }
    var sectionId = getCurrentSectionId();
    anchor.href = getHtmlBase() + (sectionId ? "#" + sectionId : "");
  }

  function initRevealJsHtmlLink() {
    var htmlBase = getHtmlBase();

    // Don't add the link if the URL doesn't follow the -slides.html convention
    if (htmlBase === window.location.href.split("#")[0]) {
      return;
    }

    // Inject styles
    var styleElement = document.createElement("style");
    styleElement.textContent = css;
    document.head.appendChild(styleElement);

    // Create the link element and append it directly to body so it stays
    // visible across all slides regardless of Reveal.js section visibility
    var div = document.createElement("div");
    div.id = "revealjs-html-link";
    var anchor = document.createElement("a");
    anchor.id = "revealjs-html-anchor";
    anchor.href = htmlBase;
    anchor.target = "_blank";
    anchor.title = "View this section in the HTML notes";
    anchor.setAttribute("aria-label", "View this section in the HTML notes");
    anchor.innerHTML = "&#128196;&nbsp;Webpage version";
    div.appendChild(anchor);
    document.body.appendChild(div);

    // Register Reveal.js slide-change listener to keep the link updated
    if (typeof Reveal !== "undefined") {
      Reveal.on("ready", updateHtmlLink);
      Reveal.on("slidechanged", updateHtmlLink);
    }

    updateHtmlLink();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initRevealJsHtmlLink);
  } else {
    initRevealJsHtmlLink();
  }
})();
</script>
]]

  doc.blocks:insert(pandoc.RawBlock("html", script))
  return doc
end
