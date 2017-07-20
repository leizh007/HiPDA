// ==========================================================================
//                            Initialization
// ==========================================================================

configureElements();

function configureElements() {
    adjustFontSize();
    addOnClickToLinks();
    replaceAvatarImageURLs();
    replaceAttatchImageURLs();
    replaceOtherImageURLs();
    hideBlockquoteImage();
}

var shouldImageAutoLoad = false;

// adjustFontSize
function adjustFontSize() {
    var fonts = document.getElementsByTagName("font");
    for (var i = 0; i < fonts.length; ++i) {
        var font = fonts[i];
        if (font.hasAttribute("size")) {
            if (parseInt(font.getAttribute("size")) >= 2) {
                font.setAttribute("size", undefined);
                font.style.fontSize = "17px";
            }
        } else {
            font.style.fontSize = "17px";
        }
        if (hexToRgb(font.getAttribute("color")) === "rgb(255, 255, 255)") {
            font.setAttribute("color", font.parentElement.tagName === "A" ? "#0000ee" : "#000000");
        }
    }
}

// ==========================================================================
//                            Image Related
// ==========================================================================

// replace avatar image url
function replaceAvatarImageURLs() {
    var avatars = document.getElementsByClassName("avatar");
    for (var i = 0; i < avatars.length; ++i) {
        var avatar = avatars[i];
        if (avatar.hasAttribute("src")) {
            var avatarURLString = avatar.getAttribute("src");
            avatarURLString = avatarURLString.replace(/^(https?|ftp):\/\//, "$&--hipda-avatar--");
            avatar.setAttribute("src", avatarURLString);
        }
    }
}

// replace attach image urls
function replaceAttatchImageURLs() {
    // t_attach
    var attatches = document.getElementsByClassName("t_attach");
    for (var i = 0; i < attatches.length; ++i) {
        var attatch = attatches[i];
        if (attatch.previousElementSibling.tagName == "SPAN") {
            attatch.previousElementSibling.setAttribute("style", "white-space: pre-wrap");
        }
        var image = attatch.previousElementSibling.getElementsByTagName("img")[0];
        if (image == undefined) {
            image = attatch.previousElementSibling;
            if (image == undefined) {
                continue;
            }
        }
        handleImageSize(image, attatch.innerText);
        handleImageURL(image);
        addOnClickToImage(image);
        image.setAttribute("style", "display: block !important; margin-left: auto !important; margin-right: auto !important;");
    }

    // t_attachlist attachimg
    var attatchList = document.getElementsByClassName("t_attachlist attachimg");
    for (var i = 0; i < attatchList.length; ++i) {
        var attatch = attatchList[i];
        var sizeString = attatch.getElementsByTagName("em")[0].innerText;
        var image = attatch.getElementsByTagName("img")[0];
        if (image != undefined) {
            handleImageSize(image, sizeString);
            handleImageURL(image);
            addOnClickToImage(image);
        }
    }
}

// 处理图片的URL，在URL的scheme后面加上hipda的标识符
function handleImageURL(image) {
    var src = image.getAttribute("src");
    if (image.hasAttribute("file")) {
        src = image.getAttribute("file");
    }
    if (/^(https?|ftp):\/\//.test(src)) {
        src = src.replace(/^(https?|ftp):\/\//, "$&--hipda-imageloading--");
    } else {
        src = "https://--hipda-imageloading--www.hi-pda.com/forum/" + src;
    }

    if (isEmoji(src)) {
        image.setAttribute("src", src.replace(/--hipda-imageloading--/, "--hipda-image--"));
    } else {
        image.setAttribute("onload", "");
        image.setAttribute("onmouseover", "");
        image.setAttribute("src", src);
        document.addEventListener("clientJSApiOnReady", function () {
            if (shouldImageAutoLoad == true) {
                image.setAttribute("src", src.replace("--hipda-imageloading--", "--hipda-image--"));
            } else {
                image.setAttribute("src", src.replace("--hipda-imageloading--", "--hipda-placeholder--"));
            }
        });
    }
    image.setAttribute("width", "auto");
}

// 图片大小处理
function handleImageSize(image, imageDescriptionText) {
    var imageSizeDesciptionArray = imageDescriptionText.match(/\(([\d\.]+)\s*(\w{2})\)/);
    if (imageSizeDesciptionArray != null && imageSizeDesciptionArray.length == 3) {
        var imageSize = parseFloat(imageSizeDesciptionArray[1]);
        var imageSizeUnit = imageSizeDesciptionArray[2];
        image.setAttribute("sizeAttributes", imageSize + imageSizeUnit);
    }
}

// 处理其余图片的URL
function replaceOtherImageURLs() {
    var images = document.getElementsByTagName("img");
    for (var i = 0; i < images.length; ++i) {
        var image = images[i];
        if (image.hasAttribute("src")) {
            var src = image.getAttribute("src");
            if (src.indexOf("--hipda-image--") !== -1 ||
                src.indexOf("--hipda-avatar--") !== -1 ||
                src.indexOf("--hipda-placeholder--") !== -1 ||
                src.indexOf("--hipda-imageloading--") !== -1) {
                continue;
            }
            handleImageURL(image);
            addOnClickToImage(image);
        } else {
            handleImageURL(image);
            addOnClickToImage(image);
        }
    }
}

// 隐藏引用中那个丑陋的图标
function hideBlockquoteImage() {
    var blockquotes = document.getElementsByTagName("blockquote");
    for (var i = 0; i < blockquotes.length; ++i) {
        var blockquote = blockquotes[i];
        var images = blockquote.getElementsByTagName("img");
        for (var j = 0; j < images.length; ++j) {
            var image = images[j];
            image.setAttribute("style", "display: none !important;");
        }
    }
}

// ==========================================================================
//                            JS Bridge
// ==========================================================================

function setupWebViewJavascriptBridge(callback) {
    if (window.WebViewJavascriptBridge) { return callback(WebViewJavascriptBridge); }
    if (window.WVJBCallbacks) { return window.WVJBCallbacks.push(callback); }
    window.WVJBCallbacks = [callback];
    var WVJBIframe = document.createElement('iframe');
    WVJBIframe.style.display = 'none';
    WVJBIframe.src = 'https://__bridge_loaded__';
    document.documentElement.appendChild(WVJBIframe);
    setTimeout(function () { document.documentElement.removeChild(WVJBIframe) }, 0)
}

setupWebViewJavascriptBridge(function (bridge) {
    bridge.callHandler("shouldImageAutoLoad", null, function responseCallback(responseData) {
        shouldImageAutoLoad = responseData;
        clientJSCodeReady();
    });

    bridge.registerHandler("jumpToPid", function (data, responseCallback) {
        var pid = data;
        var posts = document.getElementsByClassName("post");
        // window.location.hash = "#post_" + pid;
        for (var i = 0; i < posts.length; ++i) {
            posts[i].setAttribute("style", "background-color: #ffffff !important;");
        }
        document.getElementById("post_" + pid).setAttribute("style", "background-color: #eeeeee !important;");
        smoothScroll("post_" + pid);
    });

    bridge.registerHandler("scrollToTop", function (data, responseCallback) {
        var firstChild = document.body.children[0];
        smoothScroll(firstChild.id);
    });

    bridge.registerHandler("scrollToBottom", function (data, responseCallback) {
        var posts = document.getElementsByClassName("post");
        smoothScroll(null);
    });
})

function clientJSCodeReady() {
    var doc = document;
    var readyEvent = doc.createEvent("Events");
    readyEvent.initEvent("clientJSApiOnReady");
    doc.dispatchEvent(readyEvent);
}

// ==========================================================================
//                            Add Element Onclick
// ==========================================================================

function addOnClickToLinks() {
    var links = document.getElementsByTagName("a");
    for (var i = 0; i < links.length; ++i) {
        var link = links[i];
        link.setAttribute("onclick", "linkClicked(this); event.stopPropagation();");
    }
}

function addOnClickToImage(image) {
    var src = image.getAttribute("src");
    if (isEmoji(src)) {
        return;
    }
    var longpress = 500;
    var intervalID = 0;
    var start = 0;
    var moved = false;
    image.ontouchstart = function (e) {
        e.stopPropagation();
        start = new Date().getTime();
        moved = false;
        intervalID = window.setInterval(
            function () {
                window.clearInterval(intervalID);
                imageLongPressed(e.target);
            },
            longpress
        );
    };
    image.ontouchend = function (e) {
        window.clearInterval(intervalID);
        if (new Date().getTime() - start < longpress && !moved) {
            imageClicked(e.target);
        }
    };
    image.ontouchcancel = function (e) {
        window.clearInterval(intervalID);
    };
    image.ontouchmove = function (e) {
        window.clearInterval(intervalID);
        moved = true;
    };
    image.onclick = function (e) {
        e.stopPropagation();
    };
}

// ==========================================================================
//                                Element Onclick
// ==========================================================================

function imageLongPressed(image) {
    if (!imgLoaded(image)) {
        return;
    }
    if (image.getAttribute("src").indexOf("--hipda-imageloading--") !== -1) {
        return;
    }
    if (image.getAttribute("src").indexOf("--hipda-placeholder--") !== -1) {
        return;
    }
    WebViewJavascriptBridge.callHandler("imageLongPressed", image.getAttribute("src").replace("--hipda-image--", ""), function responseCallback(responseData) {
    });
}

function imageClicked(image) {
    if (!imgLoaded(image)) {
        return;
    }
    if (image.getAttribute("src").indexOf("--hipda-imageloading--") !== -1) {
        return;
    }
    if (image.getAttribute("src").indexOf("--hipda-placeholder--") !== -1) {
        var src = image.getAttribute("src");
        src = src.replace(/--hipda-placeholder--/, "--hipda-imageloading--");
        image.setAttribute("src", src);
        WebViewJavascriptBridge.callHandler("loadImage", src.replace("--hipda-imageloading--", ""), function responseCallback(responseData) {
            if (responseData === true) {
                src = src.replace("--hipda-imageloading--", "--hipda-image--");
            } else {
                src = src.replace("--hipda-imageloading--", "--hipda-placeholder--");
            }
            image.setAttribute("src", src);
        });
        return;
    }
    var src = image.getAttribute("src").replace("--hipda-image--", "");;
    var post = postDivOfChildElement(image);
    var imageSrcs = imagesToShowInPost(post);
    var data = { "imageSrcs": imageSrcs, "clickedImageSrc": src };
    WebViewJavascriptBridge.callHandler("imageClicked", data, null);
}

function postClicked(post) {
    var id = post.getAttribute("id");
    id = id.replace("post_", "");
    var pid = parseInt(id);
    id = post.getElementsByClassName("uid")[0].innerText;
    var uid = parseInt(id);
    WebViewJavascriptBridge.callHandler("postClicked", { "pid" :pid, "uid" : uid }, null);
}

function linkClicked(link) {
    WebViewJavascriptBridge.callHandler("linkActivated", link.getAttribute("href"), null);
}

function userClicked(user) {
    var uid = user.getElementsByClassName("uid")[0];
    WebViewJavascriptBridge.callHandler('userClicked', { "uid": parseInt(uid.innerText) }, null);
}

// ==========================================================================
//                                Helper
// ==========================================================================

// https://stackoverflow.com/questions/9421208/how-to-compare-a-backgroundcolor-in-javascript
// rgb中间有空格，如下形式: "rgb(255, 255, 255)"
function hexToRgb(hex) {
    if (hex == null || hex == undefined) {
        return null;
    }
    // Expand shorthand form (e.g. "03F") to full form (e.g. "0033FF")
    var shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
    hex = hex.replace(shorthandRegex, function (m, r, g, b) {
        return r + r + g + g + b + b;
    });

    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? "rgb(" + [
        parseInt(result[1], 16),
        parseInt(result[2], 16),
        parseInt(result[3], 16)
    ].join(', ') + ")" : null;
}

// 是否是表情
function isEmoji(src) {
    var isUWPTail = src.indexOf("1406211752793e731a4fec8f7b.png") !== -1;
    var isEmoji = /[\w:\/\.-]+images\/smilies\/\w+\/\w+\.gif/.test(src);
    return isUWPTail || isEmoji;
}

function postDivOfChildElement(element) {
    var elem = element;
    while (elem.tagName !== "DIV" ||
        elem.getAttribute("class") === null ||
        elem.getAttribute("class") !== "post") {
        elem = elem.parentElement;
    }
    return elem;
}

function imagesToShowInPost(post) {
    var images = post.getElementsByTagName("img");
    var srcs = []
    for (var i = 0; i < images.length; ++i) {
        var src = images[i].getAttribute("src");
        if (isEmoji(src)) {
            continue;
        }
        if (src.indexOf("--hipda-avatar--") !== -1) {
            continue;
        }
        if (src.indexOf("--hipda-placeholder--") !== -1) {
            continue;
        }
        if (src.indexOf("--hipda-imageloading--") !== -1) {
            continue;
        }
        if (src.indexOf("images/default/attachimg.gif") !== -1) {
            continue;
        }
        if (src.indexOf("images/common/back.gif") !== -1) {
            continue;
        }
        srcs[srcs.length] = src.replace("--hipda-image--", "");
    }
    return srcs;
}

function imgLoaded(imgElement) {
    return imgElement.complete && imgElement.naturalHeight !== 0;
}

// https://stackoverflow.com/questions/10063380/javascript-smooth-scroll-without-the-use-of-jquery

function currentYPosition() {
    // Firefox, Chrome, Opera, Safari
    if (self.pageYOffset) return self.pageYOffset;
    // Internet Explorer 6 - standards mode
    if (document.documentElement && document.documentElement.scrollTop)
        return document.documentElement.scrollTop;
    // Internet Explorer 6, 7 and 8
    if (document.body.scrollTop) return document.body.scrollTop;
    return 0;
}


function elmYPosition(eID) {
    if (eID == null) {
        return document.body.scrollHeight;
    }
    var elm = document.getElementById(eID);
    var y = elm.offsetTop;
    var node = elm;
    while (node.offsetParent && node.offsetParent != document.body) {
        node = node.offsetParent;
        y += node.offsetTop;
    } 
    return y;
}


function smoothScroll(eID) {
    var startY = currentYPosition();
    var stopY = elmYPosition(eID);
    var distance = stopY > startY ? stopY - startY : startY - stopY;
    if (distance < 100) {
        scrollTo(0, stopY); return;
    }
    var speed = Math.round(distance / 100);
    if (speed >= 20) speed = 20;
    var step = Math.round(distance / 25);
    var leapY = stopY > startY ? startY + step : startY - step;
    var timer = 0;
    if (stopY > startY) {
        for ( var i=startY; i<stopY; i+=step ) {
            setTimeout("window.scrollTo(0, "+leapY+")", timer * speed);
            leapY += step; if (leapY > stopY) leapY = stopY; timer++;
        } return;
    }
    for ( var i=startY; i>stopY; i-=step ) {
        setTimeout("window.scrollTo(0, "+leapY+")", timer * speed);
        leapY -= step; if (leapY < stopY) leapY = stopY; timer++;
    }
}

