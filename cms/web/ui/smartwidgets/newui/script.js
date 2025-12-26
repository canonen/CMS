var sticky = [
    'scriptCode',
    'backgroundColor',
    'showDuration',
    'closeDuration',
    'autoCloseDelay',
    'height',
    'vAlign',
    'hAlign',
    'cssLinks',
    'fixedElements',
    'fixedElementsUnaffected',
    'trigger',
    'delay',
    'scrollPercentage',
    'nonBlocking',
    'iframeLink',
    'iframeClassName',
    'cssLinks',
    'html',
    'contentType',
    'type',
    'enabled',
    'integration'
]

var drawer = [
    'scriptCode',
    'backgroundColor',
    'overlayColor',
    'showDuration',
    'closeDuration',
    'autoCloseDelay',
    'height',
    'width',
    'previewSize',
    'vAlign',
    'hAlign',
    'startPosition',
    'overlayClick',
    'overlayLock',
    'drawerStartState',
    'cssLinks',
    'trigger',
    'delay',
    'scrollPercentage',
    'nonBlocking',
    'iframeLink',
    'iframeClassName',
    'cssLinks',
    'html',
    'contentType',
    'type',
    'enabled',
    'integration'
]

var sliding = [
    'scriptCode',
    'backgroundColor',
    'overlayColor',
    'showDuration',
    'closeDuration',
    'autoCloseDelay',
    'height',
    'width',
    'vAlign',
    'hAlign',
    'startPosition',
    'endPosition',
    'overlayClick',
    'overlayLock',
    'cssLinks',
    'trigger',
    'delay',
    'scrollPercentage',
    'nonBlocking',
    'iframeLink',
    'iframeClassName',
    'cssLinks',
    'html',
    'contentType',
    'type',
    'enabled',
    'integration'
]

var fading = [
    'scriptCode',
    'backgroundColor',
    'overlayColor',
    'showDuration',
    'closeDuration',
    'autoCloseDelay',
    'height',
    'width',
    'vAlign',
    'hAlign',
    'position',
    'overlayClick',
    'overlayLock',
    'cssLinks',
    'trigger',
    'delay',
    'scrollPercentage',
    'nonBlocking',
    'iframeLink',
    'iframeClassName',
    'cssLinks',
    'html',
    'contentType',
    'type',
    'enabled',
    'integration'
]

var productAlert = [
    'scriptCode',
    'type',
    'enabled',
]

var socialProof = [
    'scriptCode',
    'type',
    'enabled'
]

var script = [
    'scriptCode',
    'trigger',
    'delay',
    'scrollPercentage',
    'type',
    'enabled',
]

var directionEnum = [
    'top left',
    'top center',
    'top right',
    'left top',
    'right top',
    'left center',
    'right center',
    'left bottom',
    'right bottom',
    'bottom left',
    'bottom center',
    'bottom right'
]
var directionEndPositionEnum = [
    'start',
    'center',
    'end'
]
var nonDirectionalPosition = [
    'top left',
    'top center',
    'top right',
    'left center',
    'center',
    'right center',
    'bottom left',
    'bottom center',
    'bottom right'
]

var hAlign = [
    'left',
    'center',
    'right'
]

var vAlign = [
    'top',
    'center',
    'bottom'
]

var fontSizeList = document.createElement('select');
fontSizeList.classList.add('no-preview');
for(var size=1;size<=7;size++) {
    var option = document.createElement('option');
    option.value = size;
    option.textContent = size;
    fontSizeList.appendChild(option);
}
var fontSizeListCopy = fontSizeList.cloneNode(true);
fontSizeList.addEventListener('change', e => {
    document.execCommand('fontSize', false, e.target.value);
});
fontSizeListCopy.addEventListener('change', e => {
    document.execCommand('fontSize', false, e.target.value);
});

document.querySelector("#showInLoop").addEventListener('change',e=>{
    if(e.target.checked)e.target.parentElement.nextElementSibling.style.display='';
    else e.target.parentElement.nextElementSibling.style.display='none';
})

document.getElementById('product_notifications_editor').firstElementChild.appendChild(fontSizeList);
document.getElementById('social_proof_editor').firstElementChild.appendChild(fontSizeListCopy);

var htmlMode = false;
var htmlMode2 = false;
function toggleHTMLMode() {
    if(htmlMode) {
        document.getElementById('richTextEditor').innerHTML = document.getElementById('richTextEditor').textContent;
        document.getElementById('richTextEditor').style.backgroundColor = '';
        document.getElementById('richTextEditor').style.color = '';
        htmlMode = false;
    } else {
        document.getElementById('richTextEditor').textContent = document.getElementById('richTextEditor').innerHTML;
        document.getElementById('richTextEditor').style.backgroundColor = 'black';
        document.getElementById('richTextEditor').style.color = '#00c900';
        htmlMode = true;
    }
}

function toggleHTMLMode2() {
    if(htmlMode2) {
        document.getElementById('richTextEditor2').innerHTML = document.getElementById('richTextEditor2').textContent;
        document.getElementById('richTextEditor2').style.backgroundColor = '';
        document.getElementById('richTextEditor2').style.color = '';
        htmlMode2 = false;
    } else {
        document.getElementById('richTextEditor2').textContent = document.getElementById('richTextEditor2').innerHTML;
        document.getElementById('richTextEditor2').style.backgroundColor = 'black';
        document.getElementById('richTextEditor2').style.color = '#00c900';
        htmlMode2 = true;
    }
}

function getProductAlertSettings() {
    var obj = {};
    var showProgressBar = document.getElementById('showProgressBar').checked;
    var prBGColor = progressBGColor.getColor();
    var prFillColor = progressFillColor.getColor();
    obj.showProgressBar = showProgressBar;
    if(showProgressBar) {
        obj.progressBGColor = prBGColor;
        obj.progressFillColor = prFillColor;
    }
    if(htmlMode) obj.content = encodeURIComponent(document.getElementById('richTextEditor').textContent);
    else obj.content = encodeURIComponent(document.getElementById('richTextEditor').innerHTML);
    obj.productIdList = Array.from(document.querySelectorAll('.productId')).map(e=>encodeURIComponent(e.value));
    obj.productNameList = Array.from(document.querySelectorAll('.productNameInclude')).map(e=>encodeURIComponent(e.value));
    obj.productNameExcludeList = Array.from(document.querySelectorAll('.productNameExclude')).map(e=>encodeURIComponent(e.value));
    obj.stockCount = document.getElementById('stockCount').value;
    obj.stockWord = document.getElementById('stockWord').value;
    obj.querySelector = document.getElementById('productAlertQuerySelector').value;
    return obj;
}

function getSocialProofSettings() {
    var obj = {};
    obj.animationType = document.getElementById('socialProofAnimation').value;
    if(obj.animationType==='sliding') {
        var position = socialProofPositionSliding.getPosition();
        obj.startPosition = position.startPosition;
        obj.endPosition = 'start';
    } else if(obj.animationType==='fading') {
        obj.position = socialProofPositionFading.getPosition().position;
    }
    obj.showInLoop = document.getElementById('showInLoop').checked ? 1 : 0;
    obj.randomizeTotalPageView = document.getElementById('randomizeTotalPageView').checked ? 1 : 0;
    obj.randomizeTotalOrder = document.getElementById('randomizeTotalOrder').checked ? 1 : 0;
    obj.randomizeTotalCart = document.getElementById('randomizeTotalCart').checked ? 1 : 0;
    obj.widgetSize = parseInt(document.getElementById('widgetSize').value);
    //obj.backgroundColor = backgroundColor2.getColor();
    obj.backgroundColor = 'rgba(0,0,0,0)';
    obj.showDuration = document.getElementById('showDuration2').value + 'ms';
    obj.closeDuration = document.getElementById('closeDuration2').value + 'ms';
    obj.autoCloseDelay = document.getElementById('autoCloseDelay2').value;
    if(obj.showInLoop==1)obj.loopInterval = document.getElementById('loopInterval').value + 'ms';
    obj.initialDelay = document.getElementById('initialDelay').value + 'ms';
    if(obj.autoCloseDelay==0)obj.autoCloseDelay='';
    else obj.autoCloseDelay += 'ms';
    obj.pageViewReferrer = document.getElementById('pageViewReferrer').value;
    obj.pageViewCountMin = document.getElementById('pageViewCountMin').value;
    obj.productViewCountMin = document.getElementById('productViewCountMin').value;
    obj.pageViewCountMax = document.getElementById('pageViewCountMax').value;
    obj.productViewCountMax = document.getElementById('productViewCountMax').value;
    obj.orderCountMin = document.getElementById('orderCountMin').value;
    obj.orderCountMax = document.getElementById('orderCountMax').value;
    obj.cartCountMin = document.getElementById('cartCountMin').value;
    obj.cartCountMax = document.getElementById('cartCountMax').value;
    obj.productIdList = Array.from(document.querySelectorAll('.productId2')).map(e=>encodeURIComponent(e.value));
    obj.productNameList = Array.from(document.querySelectorAll('.productNameInclude2')).map(e=>encodeURIComponent(e.value));
    obj.productNameExcludeList = Array.from(document.querySelectorAll('.productNameExclude2')).map(e=>encodeURIComponent(e.value));
    if(htmlMode2) obj.content = encodeURIComponent(document.getElementById('richTextEditor2').textContent);
    else obj.content = encodeURIComponent(document.getElementById('richTextEditor2').innerHTML);
    return obj;
}

function setProductAlertSettings(params) {
    document.getElementById('richTextEditor').innerHTML = decodeURIComponent(params.content);
    document.getElementById('stockCount').value = params.stockCount;
    document.getElementById('stockWord').value = params.stockWord;
    document.getElementById('productAlertQuerySelector').value = params.querySelector;
    
    if(!params.showProgressBar) {
        document.getElementById('showProgressBar').click();
    } else {
        progressBGColor.color.setColor(params.progressBGColor);
        progressFillColor.color.setColor(params.progressFillColor);
    }
    document.querySelector('#productIdList').innerHTML = '';
    params.productIdList.forEach(productId => {
        addProductId(decodeURIComponent(productId));
    });
    document.querySelector('#productNameInclude').innerHTML = '';
    params.productNameList.forEach(productName => {
        addProductNameInclude(decodeURIComponent(productName));
    });
    document.querySelector('#productNameExclude').innerHTML = '';
    params.productNameExcludeList.forEach(productName => {
        addProductNameExclude(decodeURIComponent(productName));
    });
    document.getElementById('progressBG').style.backgroundColor = params.progressBGColor;
    document.getElementById('progressFill').style.backgroundColor = params.progressFillColor;
    showProductAlertPreview();
}

function setSocialProofSettings(params) {
    document.getElementById('socialProofAnimation').value = params.animationType;
    document.getElementById('showInLoop').checked = parseInt(params.showInLoop);
    if(params.showInLoop==1)document.getElementById('showInLoop').parentElement.nextElementSibling.style.display = '';
    if(params.randomizeTotalPageView)document.getElementById('randomizeTotalPageView').checked = parseInt(params.randomizeTotalPageView);
    document.getElementById('randomizeTotalOrder').checked = parseInt(params.randomizeTotalOrder);
    document.getElementById('randomizeTotalCart').checked = parseInt(params.randomizeTotalCart);
    document.getElementById('showDuration2').setAttribute('data-slider-value', parseInt(params.showDuration));
    document.getElementById('closeDuration2').setAttribute('data-slider-value', parseInt(params.closeDuration));
    document.getElementById('initialDelay').setAttribute('data-slider-value', parseInt(params.initialDelay));
    if(params.showInLoop==1)document.getElementById('loopInterval').setAttribute('data-slider-value', parseInt(params.loopInterval));
    document.getElementById('autoCloseDelay2').setAttribute('data-slider-value', params.autoCloseDelay ? parseInt(params.autoCloseDelay) : 0);
    document.getElementById('widgetSize').setAttribute('data-slider-value', parseInt(params.widgetSize));
    backgroundColor2.color.setColor(params.backgroundColor);
    
    if(params.animationType==='sliding') {
        document.getElementById('socialProofPositionSliding').style.display = '';
        document.getElementById('socialProofPositionFading').style.display = 'none';
        socialProofPositionSliding.setValues({
            direction: directionEnum.indexOf(params.startPosition),
            selection: directionEndPositionEnum.indexOf(params.endPosition)
        });
    } else if(params.animationType==='fading') {
        document.getElementById('socialProofPositionSliding').style.display = 'none';
        document.getElementById('socialProofPositionFading').style.display = '';
        socialProofPositionFading.setValues(nonDirectionalPosition.indexOf(params.position));
    }
    if(params.pageViewReferrer)document.getElementById('pageViewReferrer').value = params.pageViewReferrer;
    document.getElementById('pageViewCountMin').value = params.pageViewCountMin;
    document.getElementById('productViewCountMin').value = params.productViewCountMin;
    document.getElementById('pageViewCountMax').value = params.pageViewCountMax;
    document.getElementById('productViewCountMax').value = params.productViewCountMax;
    document.getElementById('orderCountMin').value = params.orderCountMin;
    document.getElementById('orderCountMax').value = params.orderCountMax;
    document.getElementById('cartCountMin').value = params.cartCountMin;
    document.getElementById('cartCountMax').value = params.cartCountMax;
    
    document.querySelector('#productIdList2').innerHTML = '';
    params.productIdList.forEach(productId => {
        addProductId2(decodeURIComponent(productId));
    });
    document.querySelector('#productNameInclude2').innerHTML = '';
    params.productNameList.forEach(productName => {
        addProductNameInclude2(decodeURIComponent(productName));
    });
    document.querySelector('#productNameExclude2').innerHTML = '';
    params.productNameExcludeList.forEach(productName => {
        addProductNameExclude2(decodeURIComponent(productName));
    });
    document.getElementById('richTextEditor2').innerHTML = decodeURIComponent(params.content);
}

function addProductId(productId) {
    var productIdDiv = document.querySelector('#productIdList');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-12');
    newDiv.innerHTML = '<div class="form-group col-10"> <input value="'+(productId ? productId : '')+'" type="text" class="form-control productId" placeholder="Product Id"> </div> <div class="form-group col-2"> <button onclick="deleteListElement(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    productIdDiv.appendChild(newDiv);
}

function addProductNameInclude(productName) {
    var productIdDiv = document.querySelector('#productNameInclude');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-12');
    newDiv.innerHTML = '<div class="form-group col-10"> <input value="'+(productName ? productName : '')+'" type="text" class="form-control productNameInclude" placeholder="Product Name"> </div> <div class="form-group col-2"> <button onclick="deleteListElement(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    productIdDiv.appendChild(newDiv);
}

function addProductNameExclude(productName) {
    var productIdDiv = document.querySelector('#productNameExclude');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-12');
    newDiv.innerHTML = '<div class="form-group col-10"> <input value="'+(productName ? productName : '')+'" type="text" class="form-control productNameExclude" placeholder="Product Name"> </div> <div class="form-group col-2"> <button onclick="deleteListElement(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    productIdDiv.appendChild(newDiv);
}

function addProductId2(productId) {
    var productIdDiv = document.querySelector('#productIdList2');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-12');
    newDiv.innerHTML = '<div class="form-group col-10"> <input value="'+(productId ? productId : '')+'" type="text" class="form-control productId2" placeholder="Product Id"> </div> <div class="form-group col-2"> <button onclick="deleteListElement(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    productIdDiv.appendChild(newDiv);
}

function addProductNameInclude2(productName) {
    var productIdDiv = document.querySelector('#productNameInclude2');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-12');
    newDiv.innerHTML = '<div class="form-group col-10"> <input value="'+(productName ? productName : '')+'" type="text" class="form-control productNameInclude2" placeholder="Product Name"> </div> <div class="form-group col-2"> <button onclick="deleteListElement(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    productIdDiv.appendChild(newDiv);
}

function addProductNameExclude2(productName) {
    var productIdDiv = document.querySelector('#productNameExclude2');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-12');
    newDiv.innerHTML = '<div class="form-group col-10"> <input value="'+(productName ? productName : '')+'" type="text" class="form-control productNameExclude2" placeholder="Product Name"> </div> <div class="form-group col-2"> <button onclick="deleteListElement(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    productIdDiv.appendChild(newDiv);
}

function deleteListElement(element) {
    element.parentNode.parentNode.remove();
}

var progressFillColor = rgbaColorPicker('#progressFillColor', 'rgba(54,161,239,1)');
var progressBGColor = rgbaColorPicker('#progressBGColor', 'rgba(220,220,220,1)');
progressFillColor.setListener(function(color) {
    document.getElementById('progressFill').style.backgroundColor = color;
    showProductAlertPreview();
});
progressBGColor.setListener(function(color) {
    document.getElementById('progressBG').style.backgroundColor = color;
    showProductAlertPreview();
});
var textForeColor = 'black';
function chooseColor(el){
  var mycolor = el.value;
    el.previousElementSibling.style.color = mycolor;
  document.execCommand('foreColor', false, mycolor);
    textForeColor = mycolor;
}
var textBackgroundColor = 'white';
function chooseBackColor(el){
  var mycolor = el.value;
el.previousElementSibling.style.color = mycolor;
  document.execCommand('backColor', false, mycolor);
    textBackgroundColor = mycolor;
}
document.querySelector("#richTextEditor").addEventListener('input', showProductAlertPreview = function() {
    var HTML = htmlMode ? document.querySelector("#richTextEditor").textContent : document.querySelector("#richTextEditor").innerHTML;
    document.querySelector('.preview-panel').innerHTML = '<div></div>';
    var copyBar = document.querySelector('#progressBG').cloneNode(true);
    HTML = HTML.replace('[STOCK-COUNT]', document.getElementById('stockCount').value);
    document.querySelector('.preview-panel').firstElementChild.innerHTML += HTML;
    document.querySelector('.preview-panel').firstElementChild.appendChild(copyBar);
});


function keyReleaseUtil(callback) {
    var status = false;
    var timeoutHandler = null;
    return {
        hit: () => {
            status = true;
            if(timeoutHandler){
                clearTimeout(timeoutHandler);
                timeoutHandler = null;
            }
        },
        release: (value) => {
            if(!status)return;
            timeoutHandler = setTimeout(() => {
                status = false;
                callback(value);
            },500);
        }
    }
}

function showSocialProofPreview() {
    document.querySelector('.preview-panel').innerHTML = '';
    document.querySelector('.preview-panel').style.backgroundColor = '';
    rvtsPopup(getSmartWidgetParams(), true, custId, null, null, rcp_url).then(popup=>{
        try {
            popup.getPopup().then(function(resp) {
                if(popupPreview)popupPreview.remove();
                popupPreview = resp;
                popupPreview.style.position = 'relative';
                popupPreview.style.opacity = '1';
                popupPreview.style.top = '0';
                popupPreview.style.left = '0';
                popupPreview.style.transition = '';
                document.querySelector('.preview-panel').appendChild(popupPreview);
            });
        } catch(e) {
            document.querySelector('.preview-panel').innerHTML = 'An error has been occurred. Preview cannot be shown!'
        }
    })
}

var keyUtil = keyReleaseUtil(showSocialProofPreview);


document.querySelector("#richTextEditor2").addEventListener('input', function() {
    keyUtil.hit();
    keyUtil.release();
} );

function toggleProgressBar(element) {
    if(element.checked) {
        document.querySelector('#progressBG').style.display = '';
        document.querySelectorAll('.progressBarColor').forEach(div => {
            div.style.display = '';
        });
    } else {
        document.querySelector('#progressBG').style.display = 'none';
        document.querySelectorAll('.progressBarColor').forEach(div => {
            div.style.display = 'none';
        });
    }
    showProductAlertPreview();
}

function changeSocialProofAnimation(element) {
    if(element.value === 'sliding') {
        document.getElementById('socialProofPositionSliding').style.display = '';
        document.getElementById('socialProofPositionFading').style.display = 'none';
    } else if(element.value === 'fading') {
        document.getElementById('socialProofPositionSliding').style.display = 'none';
        document.getElementById('socialProofPositionFading').style.display = '';
    }
}

var inputList = Array.from(document.querySelectorAll('input,textarea,select'));

var backgroundColor = rgbaColorPicker('#background-color', 'rgba(54, 161, 239, 1)');
var backgroundColor2 = rgbaColorPicker('#background-color2', 'rgba(54, 161, 239, 1)');
var overlayColor = rgbaColorPicker('#overlay-color', 'rgba(0, 0, 0, 0.25)');

overlayColor.setEnabled(false);

function selectBox(rows,cols,isDirectional, directionDefault,showP) {
    var selectBox = document.createElement('div');
    var boxList = [];
    var directBoxList = [];
    var selectedBox = null;
    var selectedDirectBox = null;
    function directBoxClick(selectOnly) {
        this.classList.add('selected');
        selectedDirectBox = this;
        this.boxList[0].select();
        directBoxList.forEach(currentBox => {
            if(currentBox!==this)currentBox.classList.remove('selected');
        });
        if(showP && !selectOnly)showPreview('direct-box-select');
    }
    function boxClick(selectOnly) {
        if((directionDefault && selectedDirectBox.boxList.indexOf(this)!==0) || (isDirectional && !selectedDirectBox.boxList.includes(this)))return;
        this.classList.add('selected');
        selectedBox = this;
        boxList.forEach(currentBox => {
            if(currentBox!==this)currentBox.classList.remove('selected');
        });
        if(showP && !selectOnly)showPreview('box-select');
    }
    selectBox.classList.add('selectbox');
    var directionRowFirst = null, directionRowLast = null;
    if(isDirectional) {
        directionRowFirst = document.createElement('div');
        directionRowFirst.classList.add('selectBoxRow');
        for(var i=0;i<cols;i++) {
            var box = document.createElement('div');
            box.classList.add('selectDirectBox');
            directionRowFirst.appendChild(box);
            directBoxList.push(box);
        }
        directionRowLast = directionRowFirst.cloneNode(true);
        selectBox.appendChild(directionRowFirst);
    }
    for(var i=0;i<rows;i++) {
        var row = document.createElement('div');
        row.classList.add('selectBoxRow');
        for(var j=0;j<cols;j++) {
            if(j===0 && isDirectional) {
                var directionBox = document.createElement('div');
                directionBox.classList.add('selectDirectBox');
                row.appendChild(directionBox);
                directBoxList.push(directionBox);
            }
            var box = document.createElement('div');
            box.classList.add('selectBox');
            row.appendChild(box);
            boxList.push(box);
            box.addEventListener('click', function() { boxClick.call(this,false) });
            box.select = boxClick.bind(box, true);
            if(directionRowFirst) {
                var directionRowBox = Array.from(directionRowFirst.children)[j];
                if(!directionRowBox.boxList)directionRowBox.boxList = [];
                directionRowBox.boxList.push(box);
            }
            if(directBoxList.length > 0){
                if(!directBoxList[directBoxList.length-1].boxList)directBoxList[directBoxList.length-1].boxList = [];
                directBoxList[directBoxList.length-1].boxList.push(box);
            }
            if(j===(cols-1) && isDirectional) {
                var directionBox = document.createElement('div');
                directionBox.classList.add('selectDirectBox');
                row.appendChild(directionBox);
                directionBox.boxList = Array.from(directBoxList[directBoxList.length-1].boxList).reverse();
                directBoxList.push(directionBox);
            }
        }
        selectBox.appendChild(row);
    }
    if(isDirectional) {
        selectBox.appendChild(directionRowLast);
        Array.from(directionRowLast.children).forEach((currentBox,idx) => {
            directBoxList.push(currentBox);
            currentBox.boxList = Array.from(Array.from(directionRowFirst.children)[idx].boxList).reverse();
        });
    }
    directBoxList.forEach(currentBox => {
        currentBox.addEventListener('click', function() { directBoxClick.call(this,false) });
        currentBox.select = directBoxClick.bind(currentBox, true);
    });
    selectBox.getValues = function() {
        if(isDirectional) {
            return {
                direction: directBoxList.indexOf(selectedDirectBox),
                selection: selectedDirectBox.boxList.indexOf(selectedBox)
            };
        } else {
            return boxList.indexOf(selectedBox);
        }
    }
    selectBox.setValues = function(values) {
        if(isDirectional) {
            directBoxList[values.direction].select();
            selectedDirectBox.boxList[values.selection].select();
        } else {
            boxList[values].select();
        }
    }
    return selectBox;
}

var slidingPosition = selectBox(3,3,true);
document.getElementById('slidingPosition').appendChild(slidingPosition);
slidingPosition.getPosition = function() {
    var values = this.getValues();
    var startPosition = directionEnum[values.direction];
    var endPosition = directionEndPositionEnum[values.selection];
    return {
        startPosition: startPosition,
        endPosition: endPosition
    };
}
slidingPosition.setValues({direction:6,selection:0});

var fadingPosition = selectBox(3,3);
document.getElementById('fadingPosition').appendChild(fadingPosition);
fadingPosition.getPosition = function() {
    var position = nonDirectionalPosition[this.getValues()];
    return {
        position: position
    };
}
fadingPosition.setValues(4);

var drawerPosition = selectBox(3,3,true,true);
document.getElementById('drawerPosition').appendChild(drawerPosition);
drawerPosition.getPosition = function() {
    var startPosition = directionEnum[this.getValues().direction];
    return {
        startPosition: startPosition
    };
}
drawerPosition.setValues({direction:6,selection:0});

var socialProofPositionSliding = selectBox(3,3,true,true);
document.getElementById('socialProofPositionSliding').appendChild(socialProofPositionSliding);
socialProofPositionSliding.getPosition = function() {
    var startPosition = directionEnum[this.getValues().direction];
    return {
        startPosition: startPosition
    };
}
socialProofPositionSliding.setValues({direction:6,selection:0});

var socialProofPositionFading = selectBox(3,3);
document.getElementById('socialProofPositionFading').appendChild(socialProofPositionFading);
socialProofPositionFading.getPosition = function() {
    var position = nonDirectionalPosition[this.getValues()];
    return {
        position: position
    };
}
socialProofPositionFading.setValues(4);

var contentPosition = selectBox(3,3,false,false,true);
document.getElementById('contentPosition').appendChild(contentPosition);
contentPosition.getPosition = function() {
    var position = this.getValues();
    return {
        hAlign: position%3,
        vAlign: (position-position%3)/3
    }
}
contentPosition.setValues(4);

function getPreviewConfigs() {
    var obj = {
        noConditions: document.getElementById('noConditions').checked ? 1 : 0,
        noTriggers: document.getElementById('noTriggers').checked ? 1 : 0,
        previewType: document.getElementById('previewType').checked ? 1 : 0
    };
    return obj;
}

function savePreviewConfigs() {
    localStorage.setItem('rvts_preview_config_' + custId, JSON.stringify(getPreviewConfigs()));
}

function setPreviewConfigs(obj) {
    for(key in obj) {
        if(parseInt(obj[key])==1)document.getElementById(key).click();
    }
}

document.getElementById('previewType').addEventListener('change', e => {
    previewType = e.target.checked ? 'window' : 'iframe';
    stopLivePreview();
});

var previewResolver = null;
var previewRejecter = null;
var previewInterval = null;
var previewConnected = false;
var previewType = 'iframe';
var savedPreviewUrl = localStorage.getItem('rvts_preview_url_' + custId);
if(savedPreviewUrl)document.getElementById('previewUrl').value = savedPreviewUrl;

var previewConfig = localStorage.getItem('rvts_preview_config_' + custId);
if(previewConfig)setPreviewConfigs(JSON.parse(previewConfig));

document.getElementById('previewUrl').addEventListener('change', e => {
    localStorage.setItem('rvts_preview_url_' + custId, e.target.value);
});


function connectPreview() {
    document.getElementById('livePreviewStatus').textContent = 'Establishing Link...';
    document.getElementById('preview-connecting').style.display = '';
    document.getElementById('preview-connected').style.display = 'none';
    var timeOutCounter = 0;
    if(previewInterval) {
        clearInterval(previewInterval);
        previewInterval = null;
    }
    previewInterval = setInterval(()=>{
        if(liveFrame)liveFrame.contentWindow.postMessage({swCheckConnection:true,cust_id:custId,type:'iframe'}, document.getElementById('previewUrl').value);
        else if(liveWindow) {
            if(liveWindow.closed)stopLivePreview();
            else liveWindow.postMessage({swCheckConnection:true,cust_id:custId,type:'window'}, document.getElementById('previewUrl').value);
        }
        timeOutCounter++;
        if(timeOutCounter===30) {
            previewRejecter();
            clearInterval(previewInterval);
            previewInterval = null;
        }
    }, 1000);
}

function stopLivePreview() {
    clearInterval(previewInterval);
    previewInterval = null;
    if(document.getElementById('livePreviewStatus').textContent)document.getElementById('livePreviewStatus').textContent = 'Preview Terminated!';
    document.getElementById('preview-connecting').style.display = 'none';
    document.getElementById('preview-connected').style.display = 'none';
    if(liveFrame)liveFrame.remove();
    if(liveWindow && !liveWindow.closed)liveWindow.close();
    liveFrame=null;
    liveWindow=null;
    previewConnected = false;
}

function startLivePreview() {
    if(previewConnected) {
        var params = getSmartWidgetParams();
        params.swPreview = true;
        params.custId = custId;
        params.popupId = popup_id;
        params.rcp_link = rcp_url;
        params.formId = document.getElementById('formId').value;
        params.registerPage = registerPage;
        params.cartPage = cartPage;
        params.orderPage = orderPage;
        var noConditions = document.getElementById('noConditions').checked;
        if(noConditions) {
            var config = '{"type":"group","elements":[],"operator":"and"}';
            params.conditionConfig = JSON.parse(config);
        }
        var noTriggers = document.getElementById('noTriggers').checked;
        if(noTriggers) {
            params.trigger = 'afterLoad';
            params.delay = '0ms';
            delete params['scrollPercentage'];
        }
        if(previewType==='iframe') {
            liveFrame.contentWindow.postMessage(params, document.getElementById('previewUrl').value);
            if(liveWindow && !liveWindow.closed) {
                liveWindow.close();
            }
            liveWindow = null;
        }
        else if(previewType==='window') {
            liveWindow.postMessage(params, document.getElementById('previewUrl').value);
            if(liveFrame) {
                liveFrame.remove();
                liveFrame = null;
            }
        }
    }
}

window.addEventListener('message', message => {
    var data = message.data;
    if(data.swCheckConnection) {
        previewResolver(data.href);
        clearInterval(previewInterval);
        previewInterval = null;
    } else if(data === 'swConnectionLost') {
        var newPromise = new Promise((resolve,reject) => {
            previewResolver = resolve;
            previewRejecter = reject;
        });
        newPromise.then((href) => {
            previewConnected = true;
            document.getElementById('livePreviewStatus').textContent = 'Preview Started';
            document.getElementById('preview-connecting').style.display = 'none';
            document.getElementById('preview-connected').style.display = '';
            document.getElementById('previewUrl').value = href;
            localStorage.setItem('rvts_preview_url_' + custId, href);
            startLivePreview();
        }).catch(() => {
            previewConnected = false;
            document.getElementById('livePreviewStatus').textContent = 'Connection Timeout!';
            document.getElementById('preview-connecting').style.display = 'none';
            document.getElementById('preview-connected').style.display = 'none';
            if(liveFrame)liveFrame.remove();
        });
        connectPreview();
    }
});


var liveFrame = null;
var liveWindow = null;

window.addEventListener('beforeunload', () => {
    if(liveWindow && !liveWindow.closed)liveWindow.close();
});

function initiateLivePreview() {
    stopLivePreview();
    previewConnected = false;
    var newPromise = new Promise((resolve,reject) => {
        previewResolver = resolve;
        previewRejecter = reject;
    });
    var siteUrl = document.getElementById('previewUrl').value;
    if(previewType==='iframe') {
        if(liveFrame)liveFrame.remove();
        liveFrame = document.createElement('iframe');
        liveFrame.id = 'liveFrame';
        liveFrame.setAttribute('src',siteUrl);
        liveFrame.style.width = 'calc(100vw - 75px)';
        liveFrame.style.height = '100vh';
        document.getElementById('campaign_live_preview').appendChild(liveFrame);
    } else if(previewType==='window') {
        if(liveWindow && !liveWindow.closed)liveWindow.close();
        liveWindow = window.open(siteUrl,'Live Preview',"height="+window.outerHeight+",width="+window.outerWidth);
    }

    newPromise.then((href) => {
        previewConnected = true;
        document.getElementById('livePreviewStatus').textContent = 'Preview Started';
        document.getElementById('preview-connecting').style.display = 'none';
        document.getElementById('preview-connected').style.display = '';
        document.getElementById('previewUrl').value = href;
        localStorage.setItem('rvts_preview_url_' + custId, href);
        startLivePreview();
    }).catch(() => {
        previewConnected = false;
        document.getElementById('livePreviewStatus').textContent = 'Connection Timeout!';
        document.getElementById('preview-connecting').style.display = 'none';
        document.getElementById('preview-connected').style.display = 'none';
        if(liveFrame)liveFrame.remove();
    });
    
    connectPreview();
}

function setSmartWidgetParams(config_param) {
    var type = config_param.type;
    document.getElementById('enabled').checked = config_param.enabled;
    document.getElementById(type).select();
    if(config_param.trigger)document.getElementById(config_param.trigger).select();
    if(config_param.integration)document.getElementById(config_param.integration).select();
    if(type!=='script' && type!=='productAlert' && type!=='socialProof'){
        document.getElementById(config_param.contentType).select();
        var v = vAlign.indexOf(config_param.vAlign);
        var h = hAlign.indexOf(config_param.hAlign);
        contentPosition.setValues(v*3+h);
    }
    if(type==='sliding') {
        slidingPosition.setValues({
            direction: directionEnum.indexOf(config_param.startPosition),
            selection: directionEndPositionEnum.indexOf(config_param.endPosition)
        });
    } else if(type==='fading') {
        fadingPosition.setValues(nonDirectionalPosition.indexOf(config_param.position));
    } else if(type==='drawer') {
        drawerPosition.setValues({
            direction: directionEnum.indexOf(config_param.startPosition),
            selection: 0
        });
    }
    
    window[type].forEach(id => {
        var input = document.getElementById(id);
        if(input) {
            if(id==='delay' || id==='closeDuration' || id==='showDuration' || id==='autoCloseDelay') {
                if(config_param[id]) {
                    if(config_param[id].substr(-2,2).toLowerCase() !== 'ms' && config_param[id].substr(-1,1) === 's') {
                        config_param[id] = (parseInt(config_param[id]) * 1000) + 'ms';
                    }
                }
            }
            if(input.classList.contains('widget_slider') && (!isNaN(parseInt(config_param[id])))) {
                input.setAttribute('data-slider-value',parseInt(config_param[id]));
                console.log(id,'slider',parseInt(config_param[id]));
            } 
            else if(input.classList.contains('widget_slider') && isNaN(parseInt(config_param[id])) && (id==='height' || id==='width' || id==='autoCloseDelay')) {
                if(((id==='height' || id==='width') && config_param[id] === 'auto') || (id==='autoCloseDelay' && !config_param[id])) {
                    input.setAttribute('data-slider-value', 0);
                    console.log(id,'slider2');
                }
            }
            else if(id==='nonBlocking' && config_param.hasOwnProperty(id)) {
                input.checked = parseInt(config_param[id]);
            }
            else {
                if(config_param.hasOwnProperty(id)) {
                    input.value = config_param[id];
                    console.log(id,'input');
                }
            }
        }
    });
    if(config_param['backgroundColor'] && type !== 'script') {
        backgroundColor.color.setColor(config_param['backgroundColor']);
    }
    if(config_param['overlayColor'] && type !== 'sticky' && type !== 'script'){
        overlayColor.color.setColor(config_param['overlayColor'])
        document.getElementById('overlayColorEnabled').toggle();
    };
    if(type==='productAlert'){
        setProductAlertSettings(config_param.productAlertSettings); 
        showProductAlertPreview();
    } else if(type==='socialProof') {
        setSocialProofSettings(config_param.socialProofSettings); 
        //showSocialProofPreview();
    }
    console.log('SW Params Set');
}



function getSmartWidgetParams(forPreview) {
    var enabled = document.getElementById('enabled').checked;
    var obj = {};
    obj.enabled = enabled;
    inputList.forEach(e => {
        var name = e.name;
        var value = e.value;
        var element = e;
        if(!name)return;
        if(name==='delay' || name==='closeDuration' || name==='showDuration') {
            obj[name] = value + 'ms';
        } else if(name==='autoCloseDelay') {
            if(value==0)
                obj[name] = '';
            else
                obj[name] = value + 'ms';
        } else if(name==='height' || name==='width' || name==='previewSize') {
            if(value==0)
                obj[name] = 'auto';
            else
                obj[name] = value + 'px';
        } else {
            if(element.type === 'radio') {
                if(element.checked)
                    obj[name] = value;
            } else if(element.type === 'checkbox') {
                obj[name] = element.checked ? 1 : 0;
            } else {
                obj[name] = value;
            }
        }
    });
    var type = obj.type;
    if(type==='sliding') {
        var position = slidingPosition.getPosition();
        obj.startPosition = position.startPosition;
        obj.endPosition = position.endPosition;
    } else if(type==='fading') {
        obj.position = fadingPosition.getPosition().position;
    } else if(type==='drawer') {
        obj.startPosition = drawerPosition.getPosition().startPosition;
    }
    
    for(key in obj) {
        if(window[type] && !window[type].includes(key)) {
            delete obj[key];
        }
    }
    if(type !== 'script' && type !== 'productAlert' && type !== 'socialProof') {
        obj.backgroundColor = backgroundColor.getColor();
        var position = contentPosition.getPosition();
        obj.hAlign = hAlign[position.hAlign];
        obj.vAlign = vAlign[position.vAlign];
    }
    if(document.getElementById('overlayColorEnabled').checked) {
        obj.overlayColor = overlayColor.getColor();
    } else {
        delete obj['overlayClick'];
        delete obj['overlayLock'];
    }
    if(obj.trigger === 'afterLoad')
        delete obj['scrollPercentage'];
    else if(obj.trigger === 'scroll')
        delete obj['delay'];
    else if(obj.trigger === 'mouseLeave') {
        delete obj['scrollPercentage'];
        delete obj['delay'];
    }
    if(obj.contentType === 'iframeType') {
        delete obj['html'];
    } else if(obj.contentType === 'htmlCode') {
        delete obj['iframeLink'];
        delete obj['iframeClassName'];
    }
    if(smartWidgetConditionConfig) obj.conditionConfig = clearGroupObject(smartWidgetConditionConfig);
    if(obj.html && !forPreview)
        obj.html = encodeURIComponent(obj.html);
    if(obj.scriptCode && !forPreview)
        obj.scriptCode = encodeURIComponent(obj.scriptCode);
    if(obj.conditionConfig && !forPreview)encodeParams(obj.conditionConfig);
    if(type==='productAlert')obj.productAlertSettings = getProductAlertSettings();
    else if(type==='socialProof')obj.socialProofSettings = getSocialProofSettings();
    return obj;
}


document.getElementById('overlayColorEnabled').addEventListener('click',e=>{
    overlayColor.setEnabled(e.target.checked);
    if(!e.target.checked) {
        document.getElementById('overlayClick').parentElement.style.display = 'none';
        document.getElementById('overlayLock').parentElement.style.display = 'none';
    } else {
        document.getElementById('overlayClick').parentElement.style.display = '';
        document.getElementById('overlayLock').parentElement.style.display = '';
    }
});

document.getElementById('overlayColorEnabled').toggle = function() {
    this.checked = !this.checked
    overlayColor.setEnabled(this.checked);
    if(!this.checked) {
        document.getElementById('overlayClick').parentElement.style.display = 'none';
        document.getElementById('overlayLock').parentElement.style.display = 'none';
    } else {
        document.getElementById('overlayClick').parentElement.style.display = '';
        document.getElementById('overlayLock').parentElement.style.display = '';
    }
}

document.querySelectorAll('.nav-link').forEach(button => {
    if(button.classList.contains('campaign_live_preview') || button.classList.contains('campaign_reports')) {
        button.addEventListener('click', () => {
            document.querySelector('.preview-area').style.display = 'none';
        });
    } else {
        button.addEventListener('click', () => {
            if(!document.getElementById('script').checked)
                document.querySelector('.preview-area').style.display = '';
        });
    }
})

var popupPreview;
function showPreview(source) {
    console.log('showPreview',source);
    var params = getSmartWidgetParams(true);
    if(params.type === 'script') {
        if(popupPreview)popupPreview.remove();
        return;
    }
    document.querySelector('.preview-panel').innerHTML = '';
    document.querySelector('.preview-panel').style.backgroundColor = '';
    if(params.overlayColor)document.querySelector('.preview-panel').style.backgroundColor = params.overlayColor;
    console.log(params);
    rvtsPopup(params, true).then(popup => {
        popup.getPopup().then(function(resp) {
            if(popupPreview)popupPreview.remove();
            popupPreview = resp;
            popupPreview.style.position = 'relative';
            popupPreview.style.opacity = '1';
            popupPreview.style.top = '0';
            popupPreview.style.left = '0';
            popupPreview.style.transition = '';
            document.querySelector('.preview-panel').appendChild(popupPreview);
            Array.from(popupPreview.querySelectorAll('script')).forEach(function(scriptTag) {
                eval(scriptTag.innerHTML);
            });
        }); 
    });
}

function selectType(element) {
    showHeadMenu();
    if(element.id === 'sticky') {
        document.getElementById('slidingPosition').style.display = 'none';
        document.getElementById('fadingPosition').style.display = 'none';
        document.getElementById('drawerPosition').style.display = 'none';
        document.getElementById('drawerStartState').parentElement.style.display = 'none';
        document.getElementById('width').parentElement.parentElement.style.display = 'none';
        document.getElementById('previewSize').parentElement.parentElement.style.display = 'none';
        document.getElementById('fixedElements').parentElement.parentElement.style.display = '';
        document.getElementById('fixedElementsUnaffected').parentElement.parentElement.style.display = '';
        if(document.getElementById('overlayColorEnabled').checked)document.getElementById('overlayColorEnabled').click();
        document.getElementById('overlayColorEnabled').parentElement.parentElement.parentElement.style.display = 'none';
        document.querySelector('.campaign_design').parentElement.style.display = '';
        document.querySelector('.campaign_trigger').parentElement.style.display = '';
        document.querySelector('.campaign_integration').parentElement.style.display = '';
        document.querySelector('.campaign_product_alert').parentElement.style.display = 'none';
        document.querySelector('.campaign_social_proof').parentElement.style.display = 'none';
        document.querySelectorAll('#campaign_content > div:not(.scriptArea)').forEach(e=>e.style.display='');
        document.querySelector('.preview-area').style.display = '';
        document.querySelector('input[name=contentType]:checked').click();
    } else if(element.id === 'sliding') {
        document.getElementById('slidingPosition').style.display = '';
        document.getElementById('fadingPosition').style.display = 'none';
        document.getElementById('drawerPosition').style.display = 'none';
        document.getElementById('drawerStartState').parentElement.style.display = 'none';
        document.getElementById('width').parentElement.parentElement.style.display = '';
        document.getElementById('previewSize').parentElement.parentElement.style.display = 'none';
        document.getElementById('fixedElements').parentElement.parentElement.style.display = 'none';
        document.getElementById('fixedElementsUnaffected').parentElement.parentElement.style.display = 'none';
        document.getElementById('overlayColorEnabled').parentElement.parentElement.parentElement.style.display = '';
        document.querySelector('.campaign_design').parentElement.style.display = '';
        document.querySelector('.campaign_trigger').parentElement.style.display = '';
        document.querySelector('.campaign_integration').parentElement.style.display = '';
        document.querySelector('.campaign_product_alert').parentElement.style.display = 'none';
        document.querySelector('.campaign_social_proof').parentElement.style.display = 'none';
        document.querySelectorAll('#campaign_content > div:not(.scriptArea)').forEach(e=>e.style.display='');
        document.querySelector('.preview-area').style.display = '';
        document.querySelector('input[name=contentType]:checked').click();
    } else if(element.id === 'fading') {
        document.getElementById('slidingPosition').style.display = 'none';
        document.getElementById('fadingPosition').style.display = '';
        document.getElementById('drawerPosition').style.display = 'none';
        document.getElementById('drawerStartState').parentElement.style.display = 'none';
        document.getElementById('width').parentElement.parentElement.style.display = '';
        document.getElementById('previewSize').parentElement.parentElement.style.display = 'none';
        document.getElementById('fixedElements').parentElement.parentElement.style.display = 'none';
        document.getElementById('fixedElementsUnaffected').parentElement.parentElement.style.display = 'none';
        document.getElementById('overlayColorEnabled').parentElement.parentElement.parentElement.style.display = '';
        document.querySelector('.campaign_design').parentElement.style.display = '';
        document.querySelector('.campaign_trigger').parentElement.style.display = '';
        document.querySelector('.campaign_integration').parentElement.style.display = '';
        document.querySelector('.campaign_product_alert').parentElement.style.display = 'none';
        document.querySelector('.campaign_social_proof').parentElement.style.display = 'none';
        document.querySelectorAll('#campaign_content > div:not(.scriptArea)').forEach(e=>e.style.display='');
        document.querySelector('.preview-area').style.display = '';
        document.querySelector('input[name=contentType]:checked').click();
    } else if(element.id === 'drawer') {
        document.getElementById('slidingPosition').style.display = 'none';
        document.getElementById('fadingPosition').style.display = 'none';
        document.getElementById('drawerPosition').style.display = '';
        document.getElementById('drawerStartState').parentElement.style.display = '';
        document.getElementById('width').parentElement.parentElement.style.display = '';
        document.getElementById('previewSize').parentElement.parentElement.style.display = '';
        document.getElementById('fixedElements').parentElement.parentElement.style.display = 'none';
        document.getElementById('fixedElementsUnaffected').parentElement.parentElement.style.display = 'none';
        document.getElementById('overlayColorEnabled').parentElement.parentElement.parentElement.style.display = '';
        document.querySelector('.campaign_design').parentElement.style.display = '';
        document.querySelector('.campaign_trigger').parentElement.style.display = '';
        document.querySelector('.campaign_integration').parentElement.style.display = '';
        document.querySelector('.campaign_product_alert').parentElement.style.display = 'none';
        document.querySelector('.campaign_social_proof').parentElement.style.display = 'none';
        document.querySelectorAll('#campaign_content > div:not(.scriptArea)').forEach(e=>e.style.display='');
        document.querySelector('.preview-area').style.display = '';
        document.querySelector('input[name=contentType]:checked').click();
    } else if(element.id === 'productAlert') {
        if(document.getElementById('overlayColorEnabled').checked)document.getElementById('overlayColorEnabled').click();
        document.getElementById('overlayColorEnabled').parentElement.parentElement.parentElement.style.display = 'none';
        document.querySelector('.campaign_design').parentElement.style.display = 'none';
        document.querySelector('.campaign_trigger').parentElement.style.display = 'none';
        document.querySelector('.campaign_integration').parentElement.style.display = 'none';
        document.querySelector('.campaign_product_alert').parentElement.style.display = '';
        document.querySelector('.campaign_social_proof').parentElement.style.display = 'none';
        document.querySelectorAll('#campaign_content > div:not(.scriptArea)').forEach(e=>e.style.display='none');
        document.querySelector('.scriptArea').style.display = '';
        document.querySelector('.preview-area').style.display = '';      
    } else if(element.id === 'socialProof') {
        if(document.getElementById('overlayColorEnabled').checked)document.getElementById('overlayColorEnabled').click();
        document.getElementById('overlayColorEnabled').parentElement.parentElement.parentElement.style.display = 'none';
        document.querySelector('.campaign_design').parentElement.style.display = 'none';
        document.querySelector('.campaign_trigger').parentElement.style.display = 'none';
        document.querySelector('.campaign_integration').parentElement.style.display = 'none';
        document.querySelector('.campaign_product_alert').parentElement.style.display = 'none';
        document.querySelector('.campaign_social_proof').parentElement.style.display = '';
        document.querySelectorAll('#campaign_content > div:not(.scriptArea)').forEach(e=>e.style.display='none');
        document.querySelector('.scriptArea').style.display = '';
        document.querySelector('.preview-area').style.display = '';      
    } else if(element.id === 'script') {
        if(document.getElementById('overlayColorEnabled').checked)document.getElementById('overlayColorEnabled').click();
        document.getElementById('overlayColorEnabled').parentElement.parentElement.parentElement.style.display = 'none';
        document.querySelector('.campaign_design').parentElement.style.display = 'none';
        document.querySelector('.campaign_trigger').parentElement.style.display = '';
        document.querySelector('.campaign_integration').parentElement.style.display = 'none';
        document.querySelector('.campaign_product_alert').parentElement.style.display = 'none';
        document.querySelector('.campaign_social_proof').parentElement.style.display = 'none';
        document.querySelectorAll('#campaign_content > div:not(.scriptArea)').forEach(e=>e.style.display='none');
        document.querySelector('.scriptArea').style.display = '';
        document.querySelector('.preview-area').style.display = 'none';
    }
}

function selectTrigger(element) {
    triggerInputList.forEach((trigger,idx) => {
        if(trigger.checked) {
            if(triggerCardList[idx].classList.contains('collapsed-card')) {
                trigger.nextElementSibling.nextElementSibling.click();
            }
        } else {
            if(!triggerCardList[idx].classList.contains('collapsed-card')) {
                trigger.nextElementSibling.nextElementSibling.click();
            }
        }
    });
}

var showHeadMenu = (function() {
    var menuAlreadyShown = false;
    return function() {
        if(menuAlreadyShown)return;
        document.querySelector('.headmenu').style.display = '';
    }
})();

function selectContentType(element) {
    if(element.id === 'iframeType') {
        document.getElementById('iframeLink').parentElement.parentElement.style.display = '';
        document.getElementById('iframeClassName').parentElement.parentElement.style.display = '';
        document.getElementById('html').parentElement.style.display = 'none';
    } else if(element.id === 'htmlCode') {
        document.getElementById('iframeLink').parentElement.parentElement.style.display = 'none';
        document.getElementById('iframeClassName').parentElement.parentElement.style.display = 'none';
        document.getElementById('html').parentElement.style.display = '';
    }
}

function selectIntegration(element) {
    document.querySelectorAll('.intgr').forEach(el=>el.style.display='none');
    document.querySelector('.' + element.id).style.display = '';
}

backgroundColor.setListener(showPreview);
overlayColor.setListener(showPreview);
backgroundColor2.setListener(showSocialProofPreview);

document.querySelectorAll('input[name=type]').forEach(input => {
    input.addEventListener('click', function() {
        selectType(this);
    });
    input.select = function() {
        this.checked = true;
        selectType(this);
    }
});

var triggerInputList = [];
var triggerCardList = [];
document.querySelectorAll('input[name=trigger]').forEach(input => {
    triggerInputList.push(input);
    triggerCardList.push(input.parentElement.parentElement);
    input.addEventListener('click', function() {
        selectTrigger(this);
    });
    input.select = function() {
        this.checked = true;
        selectTrigger(this);
    }
});

document.querySelectorAll('input[name=contentType]').forEach(input => {
    input.addEventListener('click', function() {
        selectContentType(this);
    });
    input.select = function() {
        this.checked = true;
        selectContentType(this);
    }
});

document.querySelectorAll('input[name=integration]').forEach(input => {
    input.addEventListener('click', function() {
        selectIntegration(this);
    });
    input.select = function() {
        this.checked = true;
        selectIntegration(this);
    }
});

Array.from(document.querySelectorAll("input:not(.no-preview),select:not(.no-preview),textarea:not(.no-preview)")).forEach(function(element) {
    element.addEventListener('change', function(e) {
        showPreview(e.target);
    })
});

function saveConfigs(element) {
    var popup_name = document.getElementById('widgetName').value;
    if(!popup_name.trim()) {
        alert('Widget name cannot be empty!');
        document.querySelector('a.campaign_type').click();
        return;
    }
    var tempParams = getSmartWidgetParams();
    if(!tempParams.type) {
        alert('A campaign type needs to be selected');
        document.querySelector('a.campaign_type').click();
        return;
    }
    if(!tempParams.trigger && tempParams.type!=='productAlert' && tempParams.type!=='socialProof') {
        alert('A trigger needs to be selected');
        document.querySelector('a.campaign_trigger').click();
        return;
    }
    if(tempParams.type!=='productAlert' && tempParams.type!=='socialProof' && tempParams.type!=='script' && !tempParams.integration) {
        alert('An integration needs to be selected');
        document.querySelector('a.campaign_integration').click();
        return;
    }
    var saveAnswer = confirm('Are you sure you want to save configurations?');
    if(!saveAnswer)
        return;
    
    document.getElementById('config-saving').style.display = '';
    element.setAttribute('disabled','');
    var isEnabled = document.getElementById('enabled').checked ? '1' : '0';;
    var form_id = document.getElementById('formId').value;
    if(!form_id || tempParams.type==='productAlert' || tempParams.type==='socialProof' || tempParams.type==='script')form_id = 0;
    
    fetch('http://cms.revotas.com/cms/ui/smartwidgets/save_smartwidget_config.jsp?enabled='+isEnabled+'&popup_name='+popup_name+'&form_id='+form_id+'&cust_id='+custId+'&popup_id='+popup_id+'&rcp_link='+rcp_url,{	
        method: 'POST',
        headers: {
            'Content-Type':'application/json'
        },
        body: JSON.stringify(getSmartWidgetParams())
    }).then(function() {
        fetch('http://f.revotas.com/frm/smartwidgets/save_smartwidget_config.jsp?enabled='+isEnabled+'&popup_name='+popup_name+'&form_id='+form_id+'&cust_id='+custId+'&popup_id='+popup_id+'&rcp_link='+rcp_url,{	
            method: 'POST',
            headers: {
                'Content-Type':'application/json'
            },
            body: JSON.stringify(getSmartWidgetParams())
        }).then(function() {
            fetch('http://'+rcp_url+'/rrcp/imc/smartwidgets/save_smartwidget_config.jsp?enabled='+isEnabled+'&popup_name='+popup_name+'&form_id='+form_id+'&cust_id='+custId+'&popup_id='+popup_id+'',{	
                method: 'POST',
                headers: {
                    'Content-Type':'application/json'
                },
                body: JSON.stringify(getSmartWidgetParams())
            }).then(function() {
                document.getElementById('config-saving').style.display = 'none';
                element.removeAttribute('disabled');
                alert('Configurations saved successfully');
            }).catch(function() {
                document.getElementById('config-saving').style.display = 'none';
                element.removeAttribute('disabled');
                alert('An error has been occurred!');
            });
    }).catch(function() {
        document.getElementById('config-saving').style.display = 'none';
        element.removeAttribute('disabled');
        alert('An error has been occurred!');
    })

    }).catch(function() {
        document.getElementById('config-saving').style.display = 'none';
        element.removeAttribute('disabled');
        alert('An error has been occurred!');
    })
}

function cloneWidget(element) {
    var cloneAnswer = confirm('Are you sure you want to clone this configuration?');
    if(!cloneAnswer)
        return;
    
    element.setAttribute('disabled','');

    var cloneConfig = getSmartWidgetParams();
    cloneConfig.enabled = false;
    var clonePopupId = [...Array(30)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
    var form_id = document.getElementById('formId').value;
    var popup_name = document.getElementById('widgetName').value + '_Clone';
    if(!form_id)form_id=0;
    fetch('http://cms.revotas.com/cms/ui/smartwidgets/save_smartwidget_config.jsp?enabled=0&popup_name='+popup_name+'&form_id='+form_id+'&cust_id='+custId+'&popup_id=' + clonePopupId,{	
        method: 'POST',
        headers: {
            'Content-Type':'application/json'
        },
        body: JSON.stringify(cloneConfig)
    }).then(function() {
        fetch('http://f.revotas.com/frm/smartwidgets/save_smartwidget_config.jsp?enabled=0&popup_name='+popup_name+'&form_id='+form_id+'&cust_id='+custId+'&popup_id=' + clonePopupId,{	
            method: 'POST',
            headers: {
                'Content-Type':'application/json'
            },
            body: JSON.stringify(cloneConfig)
    }).then(function() {
            fetch('http://'+rcp_url+'/rrcp/imc/smartwidgets/save_smartwidget_config.jsp?enabled=0&popup_name='+popup_name+'&form_id='+form_id+'&cust_id='+custId+'&popup_id=' + clonePopupId,{	
                method: 'POST',
                headers: {
                    'Content-Type':'application/json'
                },
                body: JSON.stringify(cloneConfig)
          }).then(function() {
                window.location = 'main.jsp?popup_id=' + clonePopupId;
            }).catch(function() {
                element.removeAttribute('disabled');
                alert('An error has been occurred!');
            });
    }).catch(function() {
        element.removeAttribute('disabled');
        alert('An error has been occurred!');
    });

    }).catch(function() {
        element.removeAttribute('disabled');
        alert('An error has been occurred!');
    });
}

//Condition config part

var smartWidgetConditionConfig;

function reRender() {
    if(smartWidgetConditionConfig.htmlElement)smartWidgetConditionConfig.htmlElement.remove();
    document.querySelector('.condition-panel').appendChild(renderGroup(smartWidgetConditionConfig));
}

function generateId() {
    return 'i' + [...Array(20)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
}

function resetCheckInputs(id) {
    Array.from(document.querySelectorAll('input.condition-box:not(.'+id+'),input.group-box:not(.'+id+')')).forEach(function(element) {
        element.checked = false;
    });
}

var conditionSelect = document.createElement('select');
__smartWidgetFunctions__.forEach(function(element) {
    var option = document.createElement('option');
    option.value = element.f.name;
    option.innerText = element.name;
    option.params = element.params;
    conditionSelect.appendChild(option);
});
//conditionSelect.classList.add('config-select');
//conditionSelect.classList.add('condition-select');
conditionSelect.classList.add('form-control');
conditionSelect.style.width = '200px';

var logicSelect = document.createElement('select');
logicSelect.innerHTML = '<option value="and">AND</option>' +
    '<option value="or">OR</option>'
//logicSelect.classList.add('config-select');
//logicSelect.classList.add('condition-select');
logicSelect.classList.add('form-control');

function condition(f,params) {
    this.type = 'condition';
    this.f = f;
    this.params = [];
    var thisRef = this;
    if(params) {
        params.forEach(function(param, index) {
            if(param.type === 'list') {
                thisRef.params[index] = param.elements[0].value;
            }
        });
    }
}

var addElement = function(e) {
    e.parent = this;
    this.elements.push(e);
}

var removeElement = function(e, keep) {
    this.elements = this.elements.filter(function(obj) {
        return obj !== e;
    });
    if(this.elements.length === 0) {
        if(this.parent && !keep)
            this.parent.removeElement(this);
    }
}

function group(operator,...e) {
    this.type = 'group';
    this.elements = [];
    for(var i=0;i<e.length;i++) {
        e[i].parent = this;
        this.elements.push(e[i]);
    }
    this.operator = operator;
    this.addElement = addElement;
    this.removeElement = removeElement;
}

function clearGroupObject(groupElement) {
    var newGroup = Object.assign({},groupElement);
    delete newGroup.parent;
    delete newGroup.htmlElement;
    delete newGroup.addElement;
    delete newGroup.removeElement;
    if(groupElement.elements) newGroup.elements = groupElement.elements.map(function(element) {
        var newElement = Object.assign({},element);
        delete newElement.parent;
        delete newElement.htmlElement;
        delete newElement.addElement;
        delete newElement.removeElement;
        return clearGroupObject(newElement);
    });
    return newGroup;
};

function fillGroupObject(group) {
    if(group.type === 'group') {
        group.addElement = addElement;
        group.removeElement = removeElement;
    }
    if(!group.elements)
        return group;
    else {
        group.elements.forEach(function(element) {
            element.parent = group;
            if(element.type === 'group') {
                element.addElement = addElement;
                element.removeElement = removeElement;
            }
            fillGroupObject(element);
        });
    }
}

function renderParams(selectElement, group, preserveValues) {
    decodeParams(group);
    var params = selectElement.children[selectElement.selectedIndex].params;
    while(selectElement.nextSibling)
        selectElement.nextSibling.remove();
    if(params) {
        if(group.params.length > params.length)
            group.params.length -= group.params.length - params.length;
        params.forEach(function(param,index) {
            if(param.type === 'list') {
                var newSelect = document.createElement('select');
                //newSelect.classList.add('config-select');
                //newSelect.classList.add('condition-select');
                newSelect.classList.add('form-control');
                newSelect.style.width = 'auto';
                param.elements.forEach(function(element) {
                    var newOption = document.createElement('option');
                    newOption.value = element.value;
                    newOption.innerText = element.name;
                    newSelect.appendChild(newOption);
                });
                
                newSelect.addEventListener('change', function() {
                    group.params[index] = newSelect.value;
                });
                var elementToAdd = selectElement;
                while(elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend',newSelect);

                if(preserveValues)newSelect.value = group.params[index];
                else {
                    group.params[index] = newSelect.children[0].value;
					newSelect.value = group.params[index];
                }
            } else if(param.type === 'text') {
                var newInput = document.createElement('input');
                //newInput.classList.add('condition-input');
                newInput.classList.add('form-control');
                newInput.style.width = 'auto';
                if(group.params.length > index && preserveValues) newInput.value = group.params[index];
                newInput.addEventListener('change', function(e) {
                    group.params[index] = e.target.value;
                });
                var elementToAdd = selectElement;
                while(elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend',newInput);
                group.params[index] = newInput.value;
            } else if(param.type === 'multiline') {
                var textArea = document.createElement('textarea');
                //textArea.classList.add('condition-input');
                textArea.classList.add('form-control');
                textArea.style.width = '500px';
                textArea.style.height = '100px';
                textArea.setAttribute('rows', 1);
                if(group.params.length > index && preserveValues) textArea.value = group.params[index];
                textArea.addEventListener('change', function(e) {
                    group.params[index] = e.target.value;
                });
                var elementToAdd = selectElement;
                while(elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend',textArea);
                group.params[index] = textArea.value;
            }
        });
    } else 
        group.params = [];
}

function renderGroup(group) {
    if(group.type === 'condition') {
        var divElement = document.createElement('div')
        var checkElement = document.createElement('input');
        var deleteButton = document.createElement('button');
        deleteButton.dataObj = group;
        deleteButton.innerText = 'X';
        deleteButton.addEventListener('click', function() {
            this.dataObj.parent.removeElement(this.dataObj);
            reRender();
        });
        deleteButton.classList.add('smart-widget-button');
        deleteButton.classList.add('button-red');
        deleteButton.style.margin = '5px';
        checkElement.type = 'checkbox';
        checkElement.dataObj = group;
        checkElement.classList.add("condition-box");
        var selectElement = conditionSelect.cloneNode(true);
        var originalOptions = Array.from(conditionSelect.children);
        var newOptions = Array.from(selectElement.children);
        for(var i=0;i<originalOptions.length;i++)
            newOptions[i].params = originalOptions[i].params;
        selectElement.value = group.f;
        selectElement.dataObj = group;
        divElement.appendChild(checkElement);
        divElement.appendChild(selectElement);
        renderParams(selectElement, group, true);
        divElement.appendChild(deleteButton);
        selectElement.addEventListener('change', function(e) {
            this.dataObj.f = selectElement.value;
            renderParams(selectElement, group);
            divElement.appendChild(deleteButton);
        })
        divElement.classList.add('condition-div');
        group.htmlElement = divElement;
        return divElement;
    } else if(group.type === 'group') {
        var arr = [];
        var segmentDiv = document.createElement('div');
        segmentDiv.style.display = 'flex';
        segmentDiv.classList.add('condition-segment');
        
        var addButton = document.createElement('button');
        addButton.dataObj = group;
        addButton.innerText = 'ADD';
        addButton.addEventListener('click', function() {
            this.dataObj.addElement(new condition(__smartWidgetFunctions__[0].f.name, __smartWidgetFunctions__[0].params));
            reRender();
        });
        addButton.classList.add('smart-widget-button');
        
        var checkElement = document.createElement('input');
        checkElement.type = 'checkbox';
        checkElement.dataObj = group;
        checkElement.classList.add('group-box');
        var selectElement = logicSelect.cloneNode(true);
        selectElement.value = group.operator;
        selectElement.dataObj = group;
        var logicDiv = document.createElement('div');
        logicDiv.appendChild(checkElement);
        logicDiv.appendChild(selectElement);
        logicDiv.appendChild(addButton);
        logicDiv.style.display = 'flex';
        logicDiv.style.alignItems = 'center';

        selectElement.addEventListener('change', function() {
            this.dataObj.operator = selectElement.value;
        })

        var groupDiv = document.createElement('div');
        groupDiv.classList.add('condition-group');
        var generatedID = generateId();
        group.elements.forEach(function(element) {
            groupDiv.appendChild(renderGroup(element));
        });

        Array.from(groupDiv.children).forEach(function(element) {
            var childInput = element.querySelector("input");
            childInput.classList.add(generatedID);
            childInput.name = generatedID;
            childInput.addEventListener('click', function() {
                resetCheckInputs(childInput.name);
            });
        });

        segmentDiv.appendChild(logicDiv);
        segmentDiv.appendChild(groupDiv);

        group.htmlElement = segmentDiv;
        return segmentDiv;
    }
}

document.getElementById('group-conditions').addEventListener('click', function() {
    var parent;
    var render = false;
    var elements = Array.from(document.querySelectorAll('.condition-box:checked,.group-box:checked')).map(function(element) {
        parent = element.dataObj.parent;
        element.dataObj.parent.removeElement(element.dataObj, true);
        render = true;
        return element.dataObj;
    });
    if(!render)
        return;
    var newGroup = new group('or',...elements);
    parent.addElement(newGroup);
    reRender();
});

document.getElementById('remove-group').addEventListener('click', function() {
    Array.from(document.querySelectorAll('.group-box:checked')).forEach(function(element) {
        element.dataObj.parent.removeElement(element.dataObj);
    });
    reRender();
});

document.getElementById('ungroup-conditions').addEventListener('click', function() {
    Array.from(document.querySelectorAll('.group-box:checked')).forEach(function(element) {
        element.dataObj.elements.forEach(function(el) {
            element.dataObj.parent.addElement(el);
        });
        element.dataObj.parent.removeElement(element.dataObj);
    });
    reRender();
});