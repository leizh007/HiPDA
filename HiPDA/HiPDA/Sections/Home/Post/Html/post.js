// Initialization
configureElements();

function configureElements() {
    adjustFontSize();
    replaceAvatarImageURLs();
    replaceAttatchImageURLs();
    replaceOtherImageURLs();
}

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
    }
}

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
            if (image.tagName == "IMG") {
                image.setAttribute("src", image.getAttribute("file").replace(/^(https?|ftp):\/\//, "$&--hipda-image--"));
            }
       } else {
            handleImageURL(image);
       }
       image.setAttribute("style", "display: block !important; margin-left: auto !important; margin-right: auto !important;");
       handleImageSize(image, attatch.innerText);
    }
                                                               
    // t_attachlist attachimg
    var attatchList = document.getElementsByClassName("t_attachlist attachimg");
    for (var i = 0; i < attatchList.length; ++i) {
        var attatch = attatchList[i];
        var sizeString = attatch.getElementsByTagName("em")[0].innerText;
        var image = attatch.getElementsByTagName("img")[0];
        if (image != undefined) {
            handleImageURL(image);
            handleImageSize(iamge, sizeString);
        }
    }
}

function handleImageURL(image) {
    if (image.hasAttribute("src")) {
        var imageSrc = image.getAttribute("src");
        if (/^(https?|ftp):\/\//.test(imageSrc)) {
            image.setAttribute("src", imageSrc.replace(/^(https?|ftp):\/\//, "$&--hipda-image--"));
        } else {
            image.setAttribute("src", "https://--hipda-image--www.hi-pda.com/forum/" + imageSrc);
        }
    }
}

function handleImageSize(image, imageDescriptionText) {
    var imageSizeDesciptionArray = imageDescriptionText.match(/\(([\d\.]+)\s*(\w{2})\)/);
    if (imageSizeDesciptionArray != null && imageSizeDesciptionArray.length == 3) {
        var imageSize = parseFloat(imageSizeDesciptionArray[1]);
        var imageSizeUnit = imageSizeDesciptionArray[2];
    }
}
   
function replaceOtherImageURLs() {
    var images = document.getElementsByTagName("img");
    for (var i = 0; i < images.length; ++i) {
        var image = images[i];
        if (image.hasAttribute("src")) {
            var src = image.getAttribute("src");
            if (src.indexOf("--hipda-image--") !== -1 || src.indexOf("--hipda-avatar--") !== -1) {
                continue;
            }
            if (image.hasAttribute("file")) {
                image.setAttribute("src", image.getAttribute("file"));
            }
            handleImageURL(image);
        } else {
            image.setAttribute("src", image.getAttribute("file"));
            handleImageURL(image);
        }
    }
}
