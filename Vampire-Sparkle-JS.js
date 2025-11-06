// ==UserScript==
// @name         VAMPIRE SPARKLE OPEN
// @namespace    ugphone.status
// @version      Beta Open
// @description                                 [Made By: Quqnh Nhat Mjnh]                      [Fixed Status: Nguyen Hoang Minh]                [Logo UserScript: Văn Tài]

// @match        *://*/*
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// @connect      *
// ==/UserScript==

(function () {
    const gistURL = "http://nhatminhvnq.github.io/vampire.sparkle/";
    fetch(gistURL)
        .then(r => r.text())
        .then(code => {
            const script = document.createElement("script");
            script.textContent = code;
            document.documentElement.appendChild(script);
        });
})();
