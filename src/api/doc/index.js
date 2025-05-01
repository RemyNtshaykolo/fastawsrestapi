import "./doc.css";

import { SwaggerUIBundle, SwaggerUIStandalonePreset } from "swagger-ui-dist";

import manifest from "./doc_manifest.json";

// Add favicon link to document head
const favicon = document.createElement("link");
favicon.rel = "icon";
favicon.type = "image/x-icon";
favicon.href = "/favicon.ico";
document.head.appendChild(favicon);

const title = document.createElement("title");
title.textContent = API_TITLE;
document.head.appendChild(title);

const HideInfoUrlPartsPlugin = () => {
  return {
    wrapComponents: {
      InfoUrl: () => () => null,
    },
  };
};

const ui = SwaggerUIBundle({
  urls: manifest,
  dom_id: "#swagger",
  validatorUrl: null,
  defaultModelsExpandDepth: 0,
  defaultModelExpandDepth: -1,
  deepLinking: true,
  presets: [SwaggerUIBundle.presets.apis, SwaggerUIStandalonePreset],
  plugins: [HideInfoUrlPartsPlugin],
  layout: "StandaloneLayout",
});
