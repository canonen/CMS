var sticky = {
    'script-code' : 'scriptCode',
    'background-color' : 'backgroundColor',
    'show-duration' : 'showDuration',
    'close-duration' : 'closeDuration',
    'auto-close-delay': 'autoCloseDelay',
    'height' : 'height',
    'vertical-align' : 'vAlign',
    'horizontal-align' : 'hAlign',
    'register-page' : 'registerPage',
    'cart-page' : 'cartPage',
    'order-page' : 'orderPage',
    'css-links': 'cssLinks',
    'fixed-elements': 'fixedElements',
    'fixed-elements-unaffected': 'fixedElementsUnaffected'
}

var drawer = {
    'script-code' : 'scriptCode',
    'background-color' : 'backgroundColor',
    'overlay-color' : 'overlayColor',
    'show-duration' : 'showDuration',
    'close-duration' : 'closeDuration',
    'auto-close-delay': 'autoCloseDelay',
    'height' : 'height',
    'width' : 'width',
    'preview-size' : 'previewSize',
    'vertical-align' : 'vAlign',
    'horizontal-align' : 'hAlign',
    'start-position' : 'startPosition',
    'overlay-click': 'overlayClick',
    'overlay-lock': 'overlayLock',
    'drawer-start-state': 'drawerStartState',
    'register-page' : 'registerPage',
    'cart-page' : 'cartPage',
    'order-page' : 'orderPage',
    'css-links': 'cssLinks'
}

var drawerNoOverlay = {
    'script-code' : 'scriptCode',
    'background-color' : 'backgroundColor',
    'show-duration' : 'showDuration',
    'close-duration' : 'closeDuration',
    'auto-close-delay': 'autoCloseDelay',
    'height' : 'height',
    'width' : 'width',
    'preview-size' : 'previewSize',
    'vertical-align' : 'vAlign',
    'horizontal-align' : 'hAlign',
    'start-position' : 'startPosition',
    'drawer-start-state': 'drawerStartState',
    'register-page' : 'registerPage',
    'cart-page' : 'cartPage',
    'order-page' : 'orderPage',
    'css-links': 'cssLinks'
}

var sliding = {
    'script-code' : 'scriptCode',
    'background-color' : 'backgroundColor',
    'overlay-color' : 'overlayColor',
    'show-duration' : 'showDuration',
    'close-duration' : 'closeDuration',
    'auto-close-delay': 'autoCloseDelay',
    'height' : 'height',
    'width' : 'width',
    'vertical-align' : 'vAlign',
    'horizontal-align' : 'hAlign',
    'start-position' : 'startPosition',
    'end-position' : 'endPosition',
    'overlay-click': 'overlayClick',
    'overlay-lock': 'overlayLock',
    'register-page' : 'registerPage',
    'cart-page' : 'cartPage',
    'order-page' : 'orderPage',
    'css-links': 'cssLinks'
}

var slidingNoOverlay = {
    'script-code' : 'scriptCode',
    'background-color' : 'backgroundColor',
    'show-duration' : 'showDuration',
    'close-duration' : 'closeDuration',
    'auto-close-delay': 'autoCloseDelay',
    'height' : 'height',
    'width' : 'width',
    'vertical-align' : 'vAlign',
    'horizontal-align' : 'hAlign',
    'start-position' : 'startPosition',
    'end-position' : 'endPosition',
    'register-page' : 'registerPage',
    'cart-page' : 'cartPage',
    'order-page' : 'orderPage',
    'css-links': 'cssLinks'
}

var fading = {
    'script-code' : 'scriptCode',
    'background-color' : 'backgroundColor',
    'overlay-color' : 'overlayColor',
    'show-duration' : 'showDuration',
    'close-duration' : 'closeDuration',
    'auto-close-delay': 'autoCloseDelay',
    'height' : 'height',
    'width' : 'width',
    'vertical-align' : 'vAlign',
    'horizontal-align' : 'hAlign',
    'position' : 'position',
    'overlay-click': 'overlayClick',
    'overlay-lock': 'overlayLock',
    'register-page' : 'registerPage',
    'cart-page' : 'cartPage',
    'order-page' : 'orderPage',
    'css-links': 'cssLinks'
}

var fadingNoOverlay = {
    'script-code' : 'scriptCode',
    'background-color' : 'backgroundColor',
    'show-duration' : 'showDuration',
    'close-duration' : 'closeDuration',
    'auto-close-delay': 'autoCloseDelay',
    'height' : 'height',
    'width' : 'width',
    'vertical-align' : 'vAlign',
    'horizontal-align' : 'hAlign',
    'position' : 'position',
    'register-page' : 'registerPage',
    'cart-page' : 'cartPage',
    'order-page' : 'orderPage',
    'css-links': 'cssLinks'
}

var script = {
    'script-code' : 'scriptCode'
}

var noTrigger = {};

var afterLoad = {
    'DELAY' : 'delay'
}

var mouseLeave = {};

var scroll = {
    'scroll-percentage' : 'scrollPercentage'
}

var htmlCode = {
    'HTML': 'html'
};

var iframeType = {
    'iframe-link': 'iframeLink',
    'iframe-class-name': 'iframeClassName'
};

var list = { sticky: sticky, sliding: sliding, slidingNoOverlay: slidingNoOverlay, fading: fading, fadingNoOverlay: fadingNoOverlay, drawer: drawer, drawerNoOverlay: drawerNoOverlay, script: script };

var reverseList = {};

var triggerList = { noTrigger: noTrigger, afterLoad: afterLoad, mouseLeave: mouseLeave, scroll: scroll };

var reverseTriggerList = {};

var contentTypeList = {htmlCode: htmlCode, iframeType: iframeType};

var reverseContentTypeList = {};

for(var key in list) {
	var tempObj = Object.assign({},list[key]);
	var reverseObj = Object.assign({}, ...Object.entries(tempObj).map(([a,b]) => ({ [b]: a })))
	reverseList[key] = reverseObj;
}

for(var key in triggerList) {
	var tempObj = Object.assign({},triggerList[key]);
	var reverseObj = Object.assign({}, ...Object.entries(tempObj).map(([a,b]) => ({ [b]: a })))
	reverseTriggerList[key] = reverseObj;
}

for(var key in contentTypeList) {
	var tempObj = Object.assign({},contentTypeList[key]);
	var reverseObj = Object.assign({}, ...Object.entries(tempObj).map(([a,b]) => ({ [b]: a })))
	reverseContentTypeList[key] = reverseObj;
}

var backgroundColor = rgbaColorPicker('#background-color', 'rgba(54, 161, 239, 1)');
var overlayColor = rgbaColorPicker('#overlay-color', 'rgba(0, 0, 0, 0.25)');

select('sticky');
selectTrigger('afterLoad');
selectContentType('htmlCode');

document.getElementById('type').addEventListener('change', function() {
    var value = this.value;
    select(value);
});

document.getElementById('trigger').addEventListener('change', function() {
    var value = this.value;
    selectTrigger(value);
});

document.getElementById('content-type').addEventListener('change', function() {
    var value = this.value;
    selectContentType(value);
});

function select(value) {
    Array.from(document.querySelectorAll('.widget-control')).forEach(function(element) {
        var hide = true;
        for(var id in list[value]) {
            if(element.id === id || element.getAttribute('for') === id) {
                element.style.display = 'inline-block';
                if(element.parentNode.classList.contains('group'))
                    element.parentNode.style.display = 'inline-block';
                hide = false;
            }
        }
        if(hide) {
            element.style.display = 'none';
            if(element.parentNode.classList.contains('group')) {
                element.parentNode.style.display = 'none';
            }
        }
    });
}

function selectTrigger(value) {
    Array.from(document.querySelectorAll('.trigger-control')).forEach(function(element) {
        var hide = true;
        for(var id in triggerList[value]) {
            if(element.id === id || element.getAttribute('for') === id) {
                element.style.display = 'inline-block';
                if(element.parentNode.classList.contains('group'))
                    element.parentNode.style.display = 'inline-block';
                hide = false;
            }
        }
        if(hide) {
            element.style.display = 'none';
            if(element.parentNode.classList.contains('group'))
                element.parentNode.style.display = 'none';
        }
    });
}

function selectContentType(value) {
    Array.from(document.querySelectorAll('.content-type-control')).forEach(function(element) {
        var hide = true;
        for(var id in contentTypeList[value]) {
            if(element.id === id || element.getAttribute('for') === id) {
                element.style.display = 'inline-block';
                if(element.parentNode.classList.contains('group'))
                    element.parentNode.style.display = 'inline-block';
                hide = false;
            }
        }
        if(hide) {
            element.style.display = 'none';
            if(element.parentNode.classList.contains('group'))
                element.parentNode.style.display = 'none';
        }
    });
}

function setSmartWidgetParams(config_param) {
	var type = config_param.type;
	var type2 = config_param.type;
    var enabled = config_param.enabled;
	if(type2 === 'sliding' && !config_param['overlayColor']) type2 = 'slidingNoOverlay';
    if(type2 === 'fading' && !config_param['overlayColor']) type2 = 'fadingNoOverlay';
    if(type2 === 'drawer' && !config_param['overlayColor']) type2 = 'drawerNoOverlay';
	document.getElementById('type').value = type2;
    document.getElementById('enabled').checked = enabled;
    select(type2);

    backgroundColor.color.setColor(config_param['backgroundColor']);
    if(config_param['overlayColor'])overlayColor.color.setColor(config_param['overlayColor']);
	for(var key in config_param) {
		if(reverseList[type][key]) {
			document.getElementById(reverseList[type][key]).value = config_param[key];
		}
		if(reverseTriggerList[config_param[key]]) {
			document.getElementById('trigger').value = config_param[key];
			selectTrigger(config_param[key]);
			for(var i in reverseTriggerList[config_param[key]])
				document.getElementById(reverseTriggerList[config_param[key]][i]).value = config_param[i];
		}
        if(reverseContentTypeList[config_param[key]]) {
			document.getElementById('content-type').value = config_param[key];
			selectContentType(config_param[key]);
			for(var i in reverseContentTypeList[config_param[key]])
				document.getElementById(reverseContentTypeList[config_param[key]][i]).value = config_param[i];
		}
	}
}

function getSmartWidgetParams() {
    var obj = {};
    var type = document.getElementById('type').value;
    var trigger = document.getElementById('trigger').value;
    var contentType = document.getElementById('content-type').value;
    var enabled = document.getElementById('enabled').checked;
    obj.type = type;
    obj.trigger = trigger;
    obj.contentType = contentType;
    obj.enabled = enabled;
    if(smartWidgetConditionConfig) obj.conditionConfig = clearGroupObject(smartWidgetConditionConfig);
    Array.from(document.querySelectorAll('.widget-control,.content-type-control')).forEach(function(element) {
        if(type === 'sliding' || type === 'fading') {
            obj.backgroundColor = backgroundColor.getColor();
            obj.overlayColor = overlayColor.getColor();
        } else {
            if(type === 'slidingNoOverlay') obj.type = 'sliding';
            if(type === 'fadingNoOverlay') obj.type = 'fading';
            if(type === 'drawerNoOverlay') obj.type = 'drawer';
            obj.backgroundColor = backgroundColor.getColor();
        }
        for(var id in list[type]) {
            if(element.id === id) {
                obj[list[type][id]] = element.value;
            }
        }
    });
    Array.from(document.querySelectorAll('.trigger-control')).forEach(function(element) {
        for(var id in triggerList[trigger]) {
            if(element.id === id) {
                obj[triggerList[trigger][id]] = element.value;
            }
        }
    });
    Array.from(document.querySelectorAll('.content-type-control')).forEach(function(element) {
        for(var id in contentTypeList[contentType]) {
            if(element.id === id) {
                obj[contentTypeList[contentType][id]] = element.value;
            }
        }
    });
    return obj;
}

function getSmartWidgetParamsToSend() {
	var obj = getSmartWidgetParams();
    if(obj.html)
        obj.html = encodeURIComponent(obj.html);
    if(obj.scriptCode)
        obj.scriptCode = encodeURIComponent(obj.scriptCode);
    encodeParams(obj.conditionConfig);
	return obj;
}

var popup;

document.addEventListener('keydown',function(e){
    if(e.key === 'Escape' && popup) {
        popup.close();
        popup = null;
    }
});

document.getElementById('preview').addEventListener('click', function() {
    popup = rvtsPopup(getSmartWidgetParams(), true);
    popup.show(true);
})

var popupPreview;
function showPreview() {
    if(getSmartWidgetParams().type === 'script') {
        if(popupPreview)popupPreview.remove();
        return;
    }
    rvtsPopup(getSmartWidgetParams(), true).getPopup().then(function(resp) {
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
}


backgroundColor.setListener(showPreview);
overlayColor.setListener(showPreview);
Array.from(document.querySelectorAll("select.widget-control,input.text-input,#type,#content-type")).forEach(function(element) {
    element.addEventListener('change', function(e) {
        showPreview();
    })
});




/*****************************
******************************
*****************************/

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
conditionSelect.classList.add('config-select');
conditionSelect.classList.add('condition-select');

var logicSelect = document.createElement('select');
logicSelect.innerHTML = '<option value="and">AND</option>' +
    '<option value="or">OR</option>'
logicSelect.classList.add('config-select');
logicSelect.classList.add('condition-select');

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

function renderParams(selectElement, group) {
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
                newSelect.classList.add('config-select');
                newSelect.classList.add('condition-select');
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

                newSelect.value = group.params[index];
                if(!newSelect.value) {
                    group.params[index] = newSelect.children[0].value;
					newSelect.value = group.params[index];
                }
            } else if(param.type === 'text') {
                var newInput = document.createElement('input');
                newInput.classList.add('condition-input');
                if(group.params.length > index) newInput.value = group.params[index];
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
                textArea.classList.add('condition-input');
                textArea.setAttribute('rows', 1);
                if(group.params.length > index) textArea.value = group.params[index];
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
        renderParams(selectElement, group);
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

var htmlWindow;
var scriptWindow;

function getHtml() {
    return document.getElementById('HTML').value;
}

function getScript() {
    return document.getElementById('script-code').value;
}

function saveHtml(code) {
    document.getElementById('HTML').value = code;
    showPreview();
}

function saveScript(code) {
    document.getElementById('script-code').value = code;
    showPreview();
}

function closePopup() {
    htmlWindow.close();
}

function closeScriptWindow() {
    scriptWindow.close();
}

document.getElementById('HTML').addEventListener('click', function() {
    var width = 500;
    var height = 300;
    var left = (screen.width/2)-(width/2);
    var top = (screen.height/2)-(height/2);
    htmlWindow = window.open("htmlview.html", "Save HTML", "height="+height+",width="+width+",left="+left+",top="+top);
})

document.getElementById('script-code').addEventListener('click', function() {
    var width = 500;
    var height = 300;
    var left = (screen.width/2)-(width/2);
    var top = (screen.height/2)-(height/2);
    scriptWindow = window.open("scriptview.html", "Save Script", "height="+height+",width="+width+",left="+left+",top="+top);
})