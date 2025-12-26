/*****************************
******************************
*****************************/

var __smartWidgetFunctions__ = [];
var __smartWidgetConditionFunctions__ = {};

var hname = window.location.hostname;

var resolveRvtsMap = null;
var rvtsMapInitialized = new Promise((resolve,reject)=>{
    resolveRvtsMap = resolve;
});

function rvtsSocialProofInitMap() {
    resolveRvtsMap(true);
    resolveRvtsMap = null;
}

if(hname.substr(0,3) == 'www') {
    hname = hname.substring(3,hname.length);
}

function generateSessionId() {
    return [...Array(30)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
}

var rvtsSessionId = null;

var swSessionIdResolver = null;
var swSessionId = new Promise((resolve,reject)=>{
    swSessionIdResolver = resolve;
    if(sessionStorage.getItem('rvts_session_id'))
        resolve(sessionStorage.getItem('rvts_session_id'));
});

swSessionId.then(function(sessionId) {
    rvtsSessionId = sessionId;
    sessionStorage.setItem('rvts_session_id', sessionId);
});

var rvtsSessionIdSet = false;
window.addEventListener('storage', function(e) {
    if(e.key === 'get_rvts_session_id' && e.newValue) {
        var sessionId = sessionStorage.getItem('rvts_session_id');
        if(sessionId) {
            localStorage.setItem('rvts_local_session_id', sessionId);
            localStorage.removeItem('rvts_local_session_id');
        }
    }
    if(e.key === 'rvts_local_session_id' && e.newValue && !rvtsSessionIdSet) {
        sessionStorage.setItem('rvts_session_id',e.newValue);
        rvtsSessionIdSet = true;
        swSessionIdResolver(e.newValue);
    }
});

localStorage.setItem('get_rvts_session_id','get');
localStorage.removeItem('get_rvts_session_id');
setTimeout(()=>{
    swSessionIdResolver(generateSessionId());
},250);

var rvtsUserId = swGetCookie('revotas_web_push_user'); 

function rvtsPushSmartWidgetActivity(smartWidgetCallToActionButton, popupId) {
    var currentPopup = rvtsSmartWidgetList[popupId];
    if(smartWidgetCallToActionButton && currentPopup) {
        var custId = currentPopup.custId;
        var formId = currentPopup.formId;
        var activityType = smartWidgetCallToActionButton.getAttribute('activity_type');
        if(activityType=='click')activityType='1';
        else if(activityType=='submit')activityType='2';
        smartWidgetCallToActionButton.addEventListener('click', function(){
            var fetchParams = '';
            fetchParams+= 'cust_id='+custId;
            fetchParams+='&popup_id='+popupId;
            fetchParams+='&form_id='+formId;
            fetchParams+='&user_agent='+navigator.userAgent;
            fetchParams+='&activity_type='+activityType;
            fetchParams+='&session_id='+rvtsSessionId;
            if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
            fetchParams+='&url='+window.location.href;
            fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
            if(activityType=='1')saveSwSource(popupId);
        });
    }
}

function rvtsAddScript(scriptLink) {
    if(!scriptLink)return;
    var scriptTag = document.createElement('script');
    var resolver = null;
    var p = new Promise((resolve,reject)=>{resolver=resolve});
    scriptTag.type = 'text/javascript';
    scriptTag.onload = function() {resolver(scriptTag);};
    scriptTag.onerror = function() {resolver();};
    scriptTag.src = scriptLink;
    document.head.appendChild(scriptTag);
    return p;
}

function swGetCookie(cname) {
    var name = cname + "=";
    var decodedCookie = document.cookie;
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
            c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
        }
    }
    return "";
}

function swSetCookie(name,value,days,ckie_dmn) {
    var expires = "";
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days*24*60*60*1000));
        expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + (value || "")  + expires +";domain="+ckie_dmn+ "; path=/";
}

var swSessionConfigResolver = null;
var swSessionConfig = new Promise((resolve,reject)=>{
    swSessionConfigResolver = resolve;
    if(sessionStorage.getItem('sw_session_config'))
        resolve(sessionStorage.getItem('sw_session_config'));
});

var swSessionConfigSet = false;
window.addEventListener('storage', function(e) {
    if(e.key === 'get_sw_session_config' && e.newValue) {
        var swConfig = sessionStorage.getItem('sw_session_config');
        if(swConfig) {
            localStorage.setItem('sw_local_config', swConfig);
            localStorage.removeItem('sw_local_config');
        }
    }
    if(e.key === 'sw_local_config' && e.newValue && !swSessionConfigSet) {
        sessionStorage.setItem('sw_session_config',e.newValue);
        swSessionConfigSet = true;
        swSessionConfigResolver(e.newValue);
    }
});

localStorage.setItem('get_sw_session_config','get');
localStorage.removeItem('get_sw_session_config');
setTimeout(()=>{
    swSessionConfigResolver(null);
},250);

(function() {
    var shouldUpdate = false;
    var cName = 'rvts_product_history_array';
    var recentProducts = swGetCookie(cName);
    if(!recentProducts)return;
    var decodedProducts = null;
    try {
        decodedProducts = decodeURIComponent(recentProducts); 
    } catch(e) {
        decodedProducts = recentProducts;
    }
    var products = JSON.parse(decodedProducts);
    products = products.map(product => {
        var p = product[0];
        var index = p.image_link.indexOf('https:',1);
        if(index>0) {
            shouldUpdate = true;
            p.image_link = p.image_link.substring(index,p.image_link.length);
        }
        return product;
    });
    if(shouldUpdate) {
        swSetCookie(cName,encodeURIComponent(JSON.stringify(products)),10,hname);
    }
    else if(decodedProducts === recentProducts) {
        swSetCookie(cName,encodeURIComponent(recentProducts),10,hname);
    }
})();

function saveProductsToCookie(product) {
	product.date = new Date();
    var cName = 'rvts_product_history_array';
    var cookieProductList = decodeURIComponent(swGetCookie(cName));
    if(cookieProductList) {
        localStorage.setItem(cName,encodeURIComponent(cookieProductList));
        swSetCookie(cName,'',-1,hname);
    } else {
        cookieProductList = localStorage.getItem(cName) ? decodeURIComponent(localStorage.getItem(cName)) : null;
    }
    if(cookieProductList) {
        var productList = JSON.parse(cookieProductList);
		var tempArray = productList.filter(function(element) {
			return element[0].p_id == product.p_id;
		});
		if(tempArray.length == 0) {
			productList.unshift([product]);
		} else {
            productList = productList.map(function(element) {
                if(element[0].p_id == product.p_id)
                    return [product];
                return element;
            });
        }
        if(productList.length>10)productList.length=10;
        localStorage.setItem(cName,encodeURIComponent(JSON.stringify(productList)));
    } else {
        var productList = [];
        productList.push([product]);
        localStorage.setItem(cName,encodeURIComponent(JSON.stringify(productList)));
    }
}

if(window['PRODUCT_DATA'] && PRODUCT_DATA.length == 1) {
    var currentProduct = PRODUCT_DATA[0];
    var product = {};
    product.p_id = currentProduct.id;
    product.category_id = currentProduct.category_ids;
    product.name = currentProduct.name;
    product.image_link = currentProduct.image;
    product.product_price = currentProduct.total_base_price.toFixed(2) + ' ' + currentProduct.currency;
    product.product_sales_price = currentProduct.total_sale_price.toFixed(2) + ' ' + currentProduct.currency;
    product.link = window.location.href;
    window['rvtsSWCurrentProduct'] = product;
    window['rvtsSWCurrentProduct'].stockCount = currentProduct.quantity;
    saveProductsToCookie(product);
} else if(window['productDetailModel']) {
    var currentProduct = productDetailModel;
    var product = {};
    product.p_id = currentProduct.productId;
    product.category_id = currentProduct.productCategoryId;
    product.name = currentProduct.productName;
    product.image_link = (currentProduct.productImages[0].imagePath.indexOf('https:')!==0 ? window.location.origin : '') + currentProduct.productImages[0].imagePath;
    product.product_price = currentProduct.productPriceKDVIncluded.toFixed(2) + ' ' + currentProduct.productCurrency;
    product.link = window.location.href;
    window['rvtsSWCurrentProduct'] = product;
    window['rvtsSWCurrentProduct'].stockCount = currentProduct.totalStockAmount;
    saveProductsToCookie(product);
}

function getInformation(inf) {
    var fields = inf.split(',');
    cstid=(fields[0]).trim();
    var img = fields[2];
    dmn = (fields[3]).trim();
    revotas_popup=(fields[4]).trim();
    cust_status=(fields[1]).trim();

    var native_flag=(fields[5]).trim();
    cookie_domain=(fields[6]).trim();
    cst_type=(fields[7]).trim();

    swSetCookie('rvts_popup_inf',cstid+","+cust_status+","+native_flag+","+cookie_domain+","+cst_type,10,cookie_domain);
}

/*****************************
******************************
*****************************/

var maxInt = 2147483647;

var SMART_WIDGET_MESSAGE = 'smart_widget_message';

function formatDate(date) {
    var day = date.getDate();
    var month = date.getMonth() + 1;
    var year = date.getFullYear();
    var time = month + '/' + day + '/' + year;
    return time;
}

function countVisitTime() {
    var cname = 'rvts_user_browse_time';
    var cookieVisitTime = swGetCookie(cname);
    if(cookieVisitTime) {
        swSetCookie(cname,Number.parseInt(cookieVisitTime)+1,10,hname);
    } else {
        swSetCookie(cname,'0',10,hname);
    }
    localStorage.setItem(SMART_WIDGET_MESSAGE, 'counting');
    localStorage.removeItem(SMART_WIDGET_MESSAGE);
}

function saveLastPopupShow(popupId) {
    var cname = 'rvts_popup_last_show';
    var time = formatDate(new Date());
    var obj;
    var cookieLastShow = swGetCookie(cname);
    if(cookieLastShow) {
        try {
            obj = JSON.parse(cookieLastShow);
            obj[popupId] = time;
            swSetCookie(cname,JSON.stringify(obj),10,hname);
        } catch(e) {
            obj = {};
            obj[popupId] = time;
            swSetCookie(cname,JSON.stringify(obj),10,hname);
        }
    } else {
        obj = {};
        obj[popupId] = time;
        swSetCookie(cname,JSON.stringify(obj),10,hname);
    }
}

function saveVisitHistory() {
    var cname = 'rvts_user_history_array';
    var storageVisitHistory = localStorage.getItem(cname);
    if(storageVisitHistory) {
        var historyArray = storageVisitHistory.split('|');
        if(!historyArray.includes(window.location.href.toLowerCase())) {
            historyArray.unshift(window.location.href.toLowerCase());
            localStorage.setItem(cname,historyArray.join('|'));
        }
    } else {
        var historyArray = [window.location.href.toLowerCase()];
        localStorage.setItem(cname,historyArray.join('|'));
    }
}

var countingTime = false;

if(!window['rvtsVisitCounter']) {
    (function() {
        
        function listenToStorage() {
            return new Promise(function(resolve,reject) {
                var counter = 0;
                window.addEventListener('storage', fn = function(e) {
                    if(e.key === SMART_WIDGET_MESSAGE && !e.oldValue && e.newValue === 'counting') {
                        resolve(e.newValue);
                        window.removeEventListener('storage', fn);
                    }
                });
                setTimeout(function() {
                    reject('response timeout');
                    window.removeEventListener('storage', fn);
                }, 1000);
            });
        }
        
        
        var questionInterval = setInterval(function() {
            listenToStorage().catch(function() {
                if(countingTime)
                    return;
                clearInterval(questionInterval);
                countVisitTime();
                window['rvtsVisitCounter'] = setInterval(countVisitTime,1000,hname);
                countingTime = true;
            });
        }, 5000);
        
        
    })();
}

saveVisitHistory();

if(!window['rvtsPopupAlreadyShown'])
    window['rvtsPopupAlreadyShown'] = false;

if(!window['rvtsSmartWidgetCssLinks'])
    window['rvtsSmartWidgetCssLinks'] = [];

function saveSwSource(popupId) {
    swSetCookie('revotas_source','other',7,hname);
    swSetCookie('revotas_medium','sw',7,hname);
    swSetCookie('revotas_campaign',popupId,7,hname);
}

function getScrollPercent() {
    var h = document.documentElement,
        b = document.body,
        st = 'scrollTop',
        sh = 'scrollHeight';
    return (h[st]||b[st]) / ((h[sh]||b[sh]) - h.clientHeight) * 100;
}

var flexDirection = {
    left: 'flex-start',
    right: 'flex-end',
    top: 'flex-start',
    bottom: 'flex-end',
    center: 'center'
}

Array.from(document.body.getElementsByTagName('*')).forEach(function(element) {
   if(getComputedStyle(element).zIndex >= maxInt) {
      element.style.zIndex = maxInt - 1;
   }
});

function encodeParams(param) {
    if(param.type === 'condition') {
        param.params = param.params.map(function(e) {return encodeURIComponent(e)});
        return param.params;
    } else if(param.type === 'group') {
        for(var i=0;i<param.elements.length;i++){
            encodeParams(param.elements[i]);
        }
    } else {
        return param;
    }
}

function decodeParams(param) {
    if(param.type === 'condition') {
        param.params = param.params.map(function(e) {return decodeURIComponent(e)});
        return param.params;
    } else if(param.type === 'group') {
        for(var i=0;i<param.elements.length;i++){
            decodeParams(param.elements[i]);
        }
    } else {
        return param;
    }
}

function executeGroup(group, pagesObj, popupId) {
    var promiseList = [];
    
    decodeParams(group);
    
    function execute(param) {
        if(param.type === 'condition') {
            return param.promise;
        } else if(param.type === 'group') {
            if(param.elements.length === 1) {
                return execute(param.elements[0]);
            } else {
                if(param.elements.length === 0)
                    return true;
                else
                    return param.elements.reduce(function(acc,value) {
                        if(param.operator === 'and') return execute(acc) && execute(value);
                        else if(param.operator === 'or') return execute(acc) || execute(value);
                    });
            }
        } else {
            return param;
        }
    }
    
    (function resolve(param, pagesObj, popupId) {
        if(param.type === 'condition') {
            param.promise = __smartWidgetConditionFunctions__[param.f](...param.params, pagesObj, popupId);
            promiseList.push({obj: param, promise: param.promise});
        } else if(group.type === 'group') {
            param.elements.forEach(function(element) {
                resolve(element, pagesObj, popupId);
            });
        }
    })(group, pagesObj, popupId);
    return Promise.all(promiseList.map(function(element) {
        return element.promise;
    })).then(function(resp) {
        resp.forEach(function(result,index) {
            promiseList[index].obj.promise = result;
        });
        return execute(group);
    });
}

function parseDuration(duration) {
    if(duration.substr(-2,2) === 'ms')
        return parseInt(duration);
    else if(duration.substr(-1,1) === 's')
        return parseInt(duration)*1000;
}

function closeButton() {
    var button = document.createElement('div');
    button.style.width = '15px';
    button.style.height = '15px';
    button.style.fontSize = '9px';
    button.style.verticalAlign = 'middle';
    button.style.textAlign = 'center';
    button.style.lineHeight = '15px';
    button.style.color = 'white';
    button.style.position = 'absolute';
    button.style.fontFamily = 'sans-serif';
    button.style.top = '5px';
    button.style.right = '5px';
    button.innerHTML = 'X';
    button.style.cursor = 'pointer';
    button.style.border = '1px solid white';
    button.style.borderRadius = '50%';
    button.style.backgroundColor = 'black';
    button.classList.add('smart-widget-close-button');
    return button;
}

function minimizeButton() {
    var button = document.createElement('div');
    button.style.width = '15px';
    button.style.height = '15px';
    button.style.fontSize = '9px';
    button.style.verticalAlign = 'middle';
    button.style.textAlign = 'center';
    button.style.lineHeight = '15px';
    button.style.color = 'white';
    button.style.position = 'absolute';
    button.style.fontFamily = 'sans-serif';
    button.style.top = '5px';
    button.style.right = '25px';
    button.innerHTML = '-';
    button.style.cursor = 'pointer';
    button.style.border = '1px solid white';
    button.style.borderRadius = '50%';
    button.style.backgroundColor = 'black';
    button.classList.add('smart-widget-minimize-button');
    return button;
}

function arrowButton() {
    var button = document.createElement('div');
    button.style.width = '20px';
    button.style.height = '30px';
    button.style.fontSize = '20px';
    button.style.verticalAlign = 'middle';
    button.style.textAlign = 'center';
    button.style.lineHeight = '30px';
    button.style.color = 'white';
    button.style.fontFamily = 'sans-serif';
    button.style.position = 'absolute';
    button.style.left = '-20px';
    button.style.top = '15px';
    button.innerHTML = '<span style="color: white;animation: SWdrawerArrow1 2s infinite;">&lsaquo;</span><span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&lsaquo;</span>';
    button.style.cursor = 'pointer';
    button.style.backgroundColor = 'black';
    button.style.borderTopLeftRadius = '20px';
    button.style.borderBottomLeftRadius = '20px';
    button.style.borderTopRightRadius = '0';
    button.style.borderBottomRightRadius = '0';
    button.classList.add('smart-widget-toggle-button');
    return {
        button: button,
        setPosition: function(position) {
            if(position === 'top') {
                button.style.lineHeight = '20px';
                button.style.width = '30px';
                button.style.height = '20px';
                button.style.left = 'unset';
                button.style.right = 'unset';
                button.style.bottom = 'unset';
                button.style.top = '-20px';
                button.innerHTML = '&#8657;';
                button.style.borderTopLeftRadius = '20px';
                button.style.borderBottomLeftRadius = '0';
                button.style.borderTopRightRadius = '20px';
                button.style.borderBottomRightRadius = '0';
            } else if(position === 'bottom') {
                button.style.lineHeight = '20px';
                button.style.width = '30px';
                button.style.height = '20px';
                button.style.left = 'unset';
                button.style.right = 'unset';
                button.style.top = 'unset';
                button.style.bottom = '-20px';
                button.innerHTML = '&#8659;';
                button.style.borderTopLeftRadius = '0';
                button.style.borderBottomLeftRadius = '20px';
                button.style.borderTopRightRadius = '0';
                button.style.borderBottomRightRadius = '20px';
            } else if(position === 'left') {
                button.style.lineHeight = '30px';
                button.style.width = '20px';
                button.style.height = '30px';
                button.style.borderTopLeftRadius = '20px';
                button.style.borderBottomLeftRadius = '20px';
                button.style.borderTopRightRadius = '0';
                button.style.borderBottomRightRadius = '0';
                button.style.bottom = 'unset';
                button.style.right = 'unset';
                button.style.top = '15px';
                button.style.left = '-20px';
                button.innerHTML = '<span style="color: white;animation: SWdrawerArrow1 2s infinite;">&lsaquo;</span><span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&lsaquo;</span>';
            } else if(position === 'right') {
                button.style.lineHeight = '30px';
                button.style.width = '20px';
                button.style.height = '30px';
                button.style.borderTopLeftRadius = '0';
                button.style.borderBottomLeftRadius = '0';
                button.style.borderTopRightRadius = '20px';
                button.style.borderBottomRightRadius = '20px';
                button.style.left = 'unset';
                button.style.bottom = 'unset';
                button.style.top = '15px';
                button.style.right = '-20px';
                button.innerHTML = '<span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&rsaquo;</span><span style="color: white;animation: SWdrawerArrow1 2s infinite;">&rsaquo;</span>';
            }
        },
        setArrow: function(position) {
            if(position === 'top') {
                button.innerHTML = '&#8657;';
            } else if(position === 'bottom') {
                button.innerHTML = '&#8659;';
            } else if(position === 'left') {
                button.innerHTML = '<span style="color: white;animation: SWdrawerArrow1 2s infinite;">&lsaquo;</span><span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&lsaquo;</span>';
            } else if(position === 'right') {
                button.innerHTML = '<span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&rsaquo;</span><span style="color: white;animation: SWdrawerArrow1 2s infinite;">&rsaquo;</span>';
            }
        }
    };
}

function stickyPopup(params,widgetId) {
    var subscriptionCallbacks = [];
    var scriptRun = false;
    var scriptTags = [];

    var init;

    var tempTimeout = null;
    var close = function() {
        if(tempTimeout)return;
        if(!status.open)
            throw new Error('Popup is already hidden');
        popup.style.transition = 'top ' + closeDuration +' ease 0s';
        emptyDiv.style.height = '0';
        popup.style.top = '-' + height;
        fixedElements.forEach(function(element) {
            element.style.transition = 'top ' + closeDuration +' ease 0s';
            element.style.top = '0';
        });
        tempTimeout = setTimeout(function(){
            emptyDiv.remove();
            popup.remove();
            scriptTags.forEach(function(tag){tag.remove();});
            status.open = false;
            if(subscriptionCallbacks.length>0) {
                subscriptionCallbacks.forEach(c => {c.call(selfObject,false)});
            }
            tempTimeout = null;
        },parseDuration(closeDuration));
    };

    var status = {
        open: false
    }
    
    if(params.cssLinks) {
        params.cssLinks.split(',').forEach(function(element) {
            if(!rvtsSmartWidgetCssLinks.includes(element)) {
                var newLink = document.createElement('link');
                newLink.rel = 'stylesheet';
                newLink.type = 'text/css';
                newLink.href = element;
                document.head.appendChild(newLink);
                rvtsSmartWidgetCssLinks.push(element);
            }
        });
    }

    var showDuration = params.showDuration;
    var closeDuration = params.closeDuration;
    var height = params.height;
    var backgroundColor = params.backgroundColor;
    var vAlign = params.vAlign;
    var hAlign = params.hAlign;
    var html = params.html;
    var iframeLink = params.iframeLink;

    var emptyDiv = document.createElement('div');
    emptyDiv.style.height = '0';

    var popup = document.createElement('div');
    popup.classList.add('smart-widget-container-div');
    popup.style.backgroundColor = backgroundColor;
    popup.style.position = 'fixed';
    popup.style.width = '100vw';
    popup.style.top = '-' + height;
    popup.style.left = '0';
    popup.style.height = height;
    popup.style.zIndex = maxInt - 1;
    popup.style.display = 'flex';
    popup.style.alignItems = flexDirection[vAlign];
    popup.style.justifyContent = flexDirection[hAlign];
    
    if(html) {
        popup.innerHTML = html;
    } else if(iframeLink) {
        var iframe = document.createElement('iframe');
        params.iframeClassName.split(' ').forEach(function(element) {
            if(element)iframe.classList.add(element);
        });
        iframe.setAttribute('src',iframeLink);
        if(width.slice(-2)!=='px')width+='px';
        if(height.slice(-2)!=='px')height+='px';
        iframe.style.setProperty('width',width === 'auto' ? '100%' : width,'important');
        iframe.style.setProperty('height',height === 'auto' ? '100%' : height,'important');
        iframe.setAttribute('scrolling','no');
        iframe.setAttribute('frameborder','0');
        popup.style.width = 'auto';
        popup.style.height = 'auto';
        width = 'auto';
        height = 'auto';
        popup.appendChild(iframe);
    }
    //popup.appendChild(button);

    if(height === 'auto')  {
        var tempPopup = popup.cloneNode(true);
        tempPopup.style.visibility = 'hidden';
        document.body.insertBefore(tempPopup, document.body.firstElementChild);
        init = new Promise(function(resolve, reject) {
            setTimeout(function() {
                height = tempPopup.getBoundingClientRect().height + 'px';
                popup.style.top = '-' + height;
                tempPopup.remove();
                resolve();
            }, 500);
        });
    } else {
        init = new Promise(function(resolve, reject) {
            resolve();
        });
    }

    var fixedElements;


    var selfObject = {
        subscribe: function(subCallback) {
            subscriptionCallbacks.push(subCallback);
        },
        show: function(isPreview, custId, popupId, formId) {
            var thisPopup = this;
            init.then(function() {
                if(status.open && !isPreview)
                    throw new Error('Popup is already shown');
                popup.style.transition = 'top ' + showDuration +' ease 0s';
                fixedElements = [];
                Array.from(document.body.getElementsByTagName('*')).forEach(function(element) {
                    if(getComputedStyle(element).position === 'fixed'
                    && (getComputedStyle(element).top.substr(0,1) === '0')) {
                        if(!isNaN(parseInt(getComputedStyle(element).top)) && getComputedStyle(element).top.substr(-2,2) == 'px') element.swOldTop = parseInt(getComputedStyle(element).top);
                        fixedElements.push(element);
                    }
                })
                if(params.fixedElements) {
                    Array.from(document.querySelectorAll(params.fixedElements)).forEach(function(element) {
                        if(!isNaN(parseInt(getComputedStyle(element).top)) && getComputedStyle(element).top.substr(-2,2) == 'px') element.swOldTop = parseInt(getComputedStyle(element).top);
                        fixedElements.push(element); 
                    });
                }
                if(params.fixedElementsUnaffected) {
                    Array.from(document.querySelectorAll(params.fixedElementsUnaffected)).forEach(function(element) {
                        if(fixedElements.includes(element)) {
                            fixedElements.splice(fixedElements.indexOf(element),1);
                        }
                    });
                }
                document.body.insertBefore(popup, document.body.firstElementChild);
                document.body.insertBefore(emptyDiv, popup);
                if(!scriptRun) {
                    Array.from(popup.querySelectorAll('script')).forEach(function(scriptTag) {
                        window.eval(scriptTag.innerHTML);
                        scriptRun = true;
                    });
                }
                setTimeout(async function(){
                    emptyDiv.style.transition = 'height ' + showDuration +' ease 0s';
                    popup.style.top = 0;
                    emptyDiv.style.height = height;
                    var observer = new MutationObserver(function (mutationRecord, observer) {
                        var element = mutationRecord[0].target;
                        if(getComputedStyle(element).position == 'fixed' || getComputedStyle(element).position == 'sticky' || getComputedStyle(element).position == 'absolute') {
                            element.style.transition = 'top ' + showDuration +' ease 0s';
                            element.style.setProperty('top', ((element.swOldTop ? element.swOldTop : 0) + parseInt(height)) + 'px', 'important');
                        } else {
                            element.style.transition = '';
                            element.style.top = '';
                        }
                    });
                    fixedElements.forEach(function(element) {
                        if(getComputedStyle(element).position == 'fixed' || getComputedStyle(element).position == 'sticky' || getComputedStyle(element).position == 'absolute') {
                            element.style.transition = 'top ' + showDuration +' ease 0s';
                            element.style.setProperty('top', ((element.swOldTop ? element.swOldTop : 0) + parseInt(height)) + 'px', 'important');
                        }
                        observer.observe(element,{attributes:true});
                    });
                    for(element of Array.from(popup.getElementsByTagName('script'))) {
                        var scriptTag = await rvtsAddScript(element.src);
                        if(scriptTag)scriptTags.push(scriptTag);
                    }
                    status.open = true;
                    window['rvtsPopupAlreadyShown'] = true;
                    if(params.autoCloseDelay) {
                        setTimeout(function() {
                            if(status.open)thisPopup.close();
                        }, parseDuration(showDuration) + parseDuration(params.autoCloseDelay));
                    }
                    if(subscriptionCallbacks.length>0) {
                        subscriptionCallbacks.forEach(c => {c.call(selfObject,true)});
                    }
                    if(!isPreview) {
                        saveLastPopupShow(popupId);
                        var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id='+formId+'&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
                        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                        fetchParams += '&url='+window.location.href;
                        fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                        document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) {
                            if(smartWidgetCallToActionButton) {
                                var activityType = smartWidgetCallToActionButton.getAttribute('activity_type');
                                if(activityType=='click')activityType='1';
                                else if(activityType=='submit')activityType='2';
                                smartWidgetCallToActionButton.addEventListener('click', function(){
                                    var fetchParams = '';
                                    fetchParams+= 'cust_id='+custId;
                                    fetchParams+='&popup_id='+popupId;
                                    fetchParams+='&form_id='+formId;
                                    fetchParams+='&user_agent='+navigator.userAgent;
                                    fetchParams+='&activity_type='+activityType;
                                    fetchParams+='&session_id='+rvtsSessionId;
                                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                                    fetchParams+='&url='+window.location.href;
                                    fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                                    if(activityType=='1')saveSwSource(popupId);
                                });
                            }
                        });
                    }
                },250);
            });
        },
        close: close,
        isOpen: function() {
            return status.open;
        },
        getPopup: function() {
            return init.then(function() {
               return popup;
            });
        }
    };
    return selfObject;
}

function slidingPopup(params,widgetId,customCloseButton) {
    var subscriptionCallbacks = [];
    var closeTimeout = null;
    var closeCallback = null;

    var scriptRun = false;
    var scriptTags = [];

    var init;

    var tempTimeout = null;
    var close = function() {
        if(tempTimeout)return;
        if(!status.open)
            throw new Error('Popup is already hidden');
        popup.style.transition = ps[0] + ' ' + closeDuration + ' ease 0s';
        var s = styleToHide.split('|');
        popup.style[s[0]] = s[1];
        tempTimeout = setTimeout(function(){
            if(overlayColor) {
                popup.remove();
                overlay.remove();
                document.body.style.overflow = '';
            } else {
                popup.remove();
            }
            scriptTags.forEach(function(tag){tag.remove();});
            status.open = false;
            if(closeCallback)closeCallback();
            if(closeTimeout) {
                clearTimeout(closeTimeout);
                closeTimeout = null;
            }
            if(subscriptionCallbacks.length>0) {
                subscriptionCallbacks.forEach(c => {c.call(selfObject,false)});
            }
            tempTimeout = null;
        },parseDuration(closeDuration));
    }

    var status = {
        open: false
    }
    
    if(params.cssLinks) {
        params.cssLinks.split(',').forEach(function(element) {
            if(!rvtsSmartWidgetCssLinks.includes(element)) {
                var newLink = document.createElement('link');
                newLink.rel = 'stylesheet';
                newLink.type = 'text/css';
                newLink.href = element;
                document.head.appendChild(newLink);
                rvtsSmartWidgetCssLinks.push(element);
            }
        });
    }

    var showDuration = params.showDuration;
    var closeDuration = params.closeDuration;
    var height = params.height;
    var width = params.width;
    var backgroundColor = params.backgroundColor;
    var overlayColor = params.overlayColor;
    var startPosition = params.startPosition // 'top left' || 'right bottom' etc.
    var vAlign = params.vAlign;
    var hAlign = params.hAlign;
    var html = params.html;
    var iframeLink = params.iframeLink;
    var endPosition = params.endPosition;
    var overlayClick = params.overlayClick;
    var overlayLock = params.overlayLock;

    var overlay;

    if(overlayColor) {
        overlay = document.createElement('div')
        overlay.style.position = 'fixed';
        overlay.style.top = '0';
        overlay.style.left = '0';
        overlay.style.backgroundColor = overlayColor;
        overlay.style.zIndex = maxInt;
        overlay.style.height = '100vh';
        overlay.style.width = '100vw';
    }

    var ps = startPosition.split(' ');
    var popup = document.createElement('div');
    popup.classList.add('smart-widget-container-div');
    var button = customCloseButton ? customCloseButton : closeButton();
    button.addEventListener('click', close);

    popup.style.backgroundColor = backgroundColor;
    popup.style.width = width;
    popup.style.height = height;
    popup.style.position = 'fixed';
    popup.style.display = 'flex';
    popup.style.alignItems = flexDirection[vAlign];
    popup.style.justifyContent = flexDirection[hAlign];
    
    var iframe = null;
    var iframeResolver = null;
    var iframeLoaded = null;
    if(html) {
        popup.innerHTML = html;
    } else if(iframeLink) {
        iframeLoaded = new Promise((resolve,reject)=>{iframeResolver=resolve;});
        iframe = document.createElement('iframe');
        iframe.onload = function() {iframeResolver();}
        params.iframeClassName.split(' ').forEach(function(element) {
            if(element)iframe.classList.add(element);
        });
        iframe.setAttribute('src',iframeLink);
        if(width.slice(-2)!=='px')width+='px';
        if(height.slice(-2)!=='px')height+='px';
        iframe.style.setProperty('width',width === 'auto' ? '100%' : width,'important');
        iframe.style.setProperty('height',height === 'auto' ? '100%' : height,'important');
        iframe.setAttribute('scrolling','no');
        iframe.setAttribute('frameborder','0');
        popup.style.width = 'auto';
        popup.style.height = 'auto';
        width = 'auto';
        height = 'auto';
        popup.appendChild(iframe);
    }
    popup.appendChild(button);

    var styleToShow = '';
    var styleToHide = '';

    if(height === 'auto' || width === 'auto') {
        var tempPopup = popup.cloneNode(true);
        tempPopup.style.visibility = 'hidden';
        document.body.insertBefore(tempPopup, document.body.firstElementChild);
        init = new Promise(function(resolve, reject) {
            setTimeout(function() {
                if(height === 'auto') height = tempPopup.getBoundingClientRect().height + 'px';
                if(width === 'auto') width = tempPopup.getBoundingClientRect().width + 'px';
                tempPopup.remove();
                var value;
                if(ps[0] === 'top' || ps[0] === 'bottom') {
                    value = height;
                    if(ps[1] === 'center')
                        popup.style.left = 'calc(50% - ' + parseInt(width)/2 + 'px)';
                    else
                        popup.style[ps[1]] = '0';
                }
                else if(ps[0] === 'left' || ps[0] === 'right') {
                    value = width;
                    if(ps[1] === 'center')
                        popup.style.top = 'calc(50% - ' + parseInt(height)/2 + 'px)';
                    else
                        popup.style[ps[1]] = '0';
                }

                popup.style[ps[0]] = '-' + value;

                if(endPosition === 'start')
                    styleToShow = ps[0] + '|0px';
                else if(endPosition === 'center')
                    styleToShow = ps[0] + '|calc(50% - ' + parseInt(value)/2 + 'px)';
                else if(endPosition === 'end')
                    styleToShow = ps[0] + '|calc(100% - ' + parseInt(value) + 'px)';
                styleToHide = ps[0] + '|-' + value;
                resolve();
            }, 500);
        });
    } else {
        init = new Promise(function(resolve, reject) {
            var value;
            if(ps[0] === 'top' || ps[0] === 'bottom') {
                value = height;
                if(ps[1] === 'center')
                    popup.style.left = 'calc(50% - ' + parseInt(width)/2 + 'px)';
                else
                    popup.style[ps[1]] = '0';
            }
            else if(ps[0] === 'left' || ps[0] === 'right') {
                value = width;
                if(ps[1] === 'center')
                    popup.style.top = 'calc(50% - ' + parseInt(height)/2 + 'px)';
                else
                    popup.style[ps[1]] = '0';
            }

            popup.style[ps[0]] = '-' + value;

            if(endPosition === 'start')
                styleToShow = ps[0] + '|0px';
            else if(endPosition === 'center')
                styleToShow = ps[0] + '|calc(50% - ' + parseInt(value)/2 + 'px)';
            else if(endPosition === 'end')
                styleToShow = ps[0] + '|calc(100% - ' + parseInt(value) + 'px)';
            styleToHide = ps[0] + '|-' + value;
            resolve();
        });
    }
    
    var overlayListenerAdded = false;

    var selfObject = {
        subscribe: function(subCallback) {
            subscriptionCallbacks.push(subCallback);
        },
        show: function(isPreview, custId, popupId, formId, callback) {
            if(callback)closeCallback = callback;
            var thisPopup = this;
            init.then(function() {
                if(status.open && !isPreview)
                    throw new Error('Popup is already shown');
                popup.style.transition = ps[0] + ' ' + showDuration + ' ease 0s';
                if(overlayColor) {
                    if(overlayLock!=='false')document.body.style.overflow = 'hidden';
                    document.body.insertBefore(overlay, document.body.firstElementChild);
                    overlay.appendChild(popup);
                    if(!scriptRun) {
                        Array.from(popup.querySelectorAll('script')).forEach(function(scriptTag) {
                            window.eval(scriptTag.innerHTML);
                            scriptRun = true;
                        });
                    }
                    if(overlayClick === 'close') {
                        if(!overlayListenerAdded) {
                            overlay.addEventListener('click', function() {
                                thisPopup.close();
                            });
                            overlayListenerAdded = true;
                        }
                    }
                } else {
                    popup.style.zIndex = maxInt;
                    document.body.insertBefore(popup, document.body.firstElementChild);
                    if(!scriptRun) {
                        Array.from(popup.querySelectorAll('script')).forEach(function(scriptTag) {
                            window.eval(scriptTag.innerHTML);
                            scriptRun = true;
                        });
                    }
                }
                setTimeout(async function(){
                    var s = styleToShow.split('|');
                    popup.style[s[0]] = s[1];
                    for(element of Array.from(popup.getElementsByTagName('script'))) {
                        var scriptTag = await rvtsAddScript(element.src);
                        if(scriptTag)scriptTags.push(scriptTag);
                    }
                    status.open = true;
                    window['rvtsPopupAlreadyShown'] = true;
                    if(params.autoCloseDelay) {
                        closeTimeout = setTimeout(function() {
                            if(status.open)thisPopup.close();
                            closeTimeout = null;
                        }, parseDuration(showDuration) + parseDuration(params.autoCloseDelay));
                    }
                    if(subscriptionCallbacks.length>0) {
                        subscriptionCallbacks.forEach(c => {c.call(selfObject,true)});
                    }
                    if(!isPreview) {
                        saveLastPopupShow(popupId);
                        var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id='+formId+'&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
                        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                        fetchParams += '&url='+window.location.href;
                        fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                        document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) {
                            if(smartWidgetCallToActionButton) {
                                var activityType = smartWidgetCallToActionButton.getAttribute('activity_type');
                                if(activityType=='click')activityType='1';
                                else if(activityType=='submit')activityType='2';
                                smartWidgetCallToActionButton.addEventListener('click', function(){
                                    var fetchParams = '';
                                    fetchParams+= 'cust_id='+custId;
                                    fetchParams+='&popup_id='+popupId;
                                    fetchParams+='&form_id='+formId;
                                    fetchParams+='&user_agent='+navigator.userAgent;
                                    fetchParams+='&activity_type='+activityType;
                                    fetchParams+='&session_id='+rvtsSessionId;
                                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                                    fetchParams+='&url='+window.location.href;
                                    fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                                    if(activityType=='1')saveSwSource(popupId);
                                });
                            }
                        });
                        var iframeEvalString = "var rvtsUserId='"+rvtsUserId+"'; document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) { if(smartWidgetCallToActionButton) { var activityType = smartWidgetCallToActionButton.getAttribute('activity_type'); if(activityType=='click')activityType='1'; else if(activityType=='submit')activityType='2'; smartWidgetCallToActionButton.addEventListener('click', function(){ var fetchParams = ''; fetchParams+= 'cust_id="+custId+"'; fetchParams+='&popup_id="+popupId+"'; fetchParams+='&form_id="+formId+"';  fetchParams+='&user_agent='+navigator.userAgent; fetchParams+='&activity_type='+activityType; fetchParams+='&session_id="+rvtsSessionId+"'; if(rvtsUserId)fetchParams += '&user_id="+rvtsUserId+"'; fetchParams+='&url="+window.location.href+"'; fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);  }); } });"
                        if(iframe) {
                            var messageObject = {
                                swExecJSCode: true,
                                popupId: popupId,
                                JSCode: encodeURIComponent(iframeEvalString)
                            }
                            iframeLoaded.then(() => {
                                iframe.contentWindow.postMessage(messageObject, iframeLink);
                            });
                        }
                    }
                },250);
            });
        },
        close: close,
        isOpen: function() {
            return status.open;
        },
        getPopup: function() {
            return init.then(function() {
               return popup;
            });
        }
    }
    return selfObject;
}

function fadingPopup(params,widgetId,customCloseButton) {
    var subscriptionCallbacks = [];
    var closeTimeout = null;
    var closeCallback = null;

    var scriptRun = false;
    var scriptTags = [];

    var init;
    
    var tempTimeout = null;
    var close = function() {
        if(tempTimeout)return;
        if(!status.open)
            throw new Error('Popup is already hidden');
        popup.style.transition = 'opacity ' + closeDuration + ' ease 0s';
        popup.style.opacity = '0';
        if(overlayColor) {
            overlay.style.transition = 'opacity ' + closeDuration + ' ease 0s';
            overlay.style.opacity = '0';
        }
        tempTimeout = setTimeout(function(){
            if(overlayColor) {
                popup.remove();
                overlay.remove();
                document.body.style.overflow = '';
            } else {
                popup.remove();
            }
            scriptTags.forEach(function(tag){tag.remove();});
            status.open = false;
            if(closeCallback)closeCallback();
            if(closeTimeout) {
                clearTimeout(closeTimeout);
                closeTimeout = null;
            }
            if(subscriptionCallbacks.length>0) {
                subscriptionCallbacks.forEach(c => {c.call(selfObject,false)});
            }
            tempTimeout = null;
        },parseDuration(closeDuration));
    }

    var status = {
        open: false
    }
    
    if(params.cssLinks) {
        params.cssLinks.split(',').forEach(function(element) {
            if(!rvtsSmartWidgetCssLinks.includes(element)) {
                var newLink = document.createElement('link');
                newLink.rel = 'stylesheet';
                newLink.type = 'text/css';
                newLink.href = element;
                document.head.appendChild(newLink);
                rvtsSmartWidgetCssLinks.push(element);
            }
        });
    }

    var showDuration = params.showDuration;
    var closeDuration = params.closeDuration;
    var height = params.height;
    var width = params.width;
    var backgroundColor = params.backgroundColor;
    var overlayColor = params.overlayColor;
    var position = params.position // 'top left' || 'right bottom' etc.
    var vAlign = params.vAlign;
    var hAlign = params.hAlign;
    var html = params.html;
    var iframeLink = params.iframeLink;
    var overlayClick = params.overlayClick;
    var overlayLock = params.overlayLock;

    var overlay;

    if(overlayColor) {
        overlay = document.createElement('div')
        overlay.style.position = 'fixed';
        overlay.style.top = '0';
        overlay.style.left = '0';
        overlay.style.backgroundColor = overlayColor;
        overlay.style.zIndex = maxInt;
        overlay.style.height = '100vh';
        overlay.style.width = '100vw';
        overlay.style.opacity = '0';
    }
    
    var popup = document.createElement('div');
    popup.classList.add('smart-widget-container-div');

    var button = customCloseButton ? customCloseButton : closeButton();

    var ps = position.split(' ');
    

    button.addEventListener('click', close);
    popup.style.backgroundColor = backgroundColor;
    popup.style.width = width;
    popup.style.height = height;
    popup.style.position = 'fixed';
    popup.style.display = 'flex';
    popup.style.alignItems = flexDirection[vAlign];
    popup.style.justifyContent = flexDirection[hAlign];
    popup.style.opacity = '0';
    
    var iframe = null;
    var iframeResolver = null;
    var iframeLoaded = null;
    if(html) {
        popup.innerHTML = html;
    } else if(iframeLink) {
        iframeLoaded = new Promise((resolve,reject)=>{iframeResolver=resolve;});
        iframe = document.createElement('iframe');
        iframe.onload = function() {iframeResolver();}
        params.iframeClassName.split(' ').forEach(function(element) {
            if(element)iframe.classList.add(element);
        });
        iframe.setAttribute('src',iframeLink);
        if(width.slice(-2)!=='px')width+='px';
        if(height.slice(-2)!=='px')height+='px';
        iframe.style.setProperty('width',width === 'auto' ? '100%' : width,'important');
        iframe.style.setProperty('height',height === 'auto' ? '100%' : height,'important');
        iframe.setAttribute('scrolling','no');
        iframe.setAttribute('frameborder','0');
        popup.style.width = 'auto';
        popup.style.height = 'auto';
        width = 'auto';
        height = 'auto';
        popup.appendChild(iframe);
    }
    popup.appendChild(button);

    if(height === 'auto' || width === 'auto') {
        var tempPopup = popup.cloneNode(true);
        tempPopup.style.visibility = 'hidden';
        document.body.insertBefore(tempPopup, document.body.firstElementChild);
        init = new Promise(function(resolve, reject) {
            setTimeout(function() {
                if(height === 'auto') height = tempPopup.getBoundingClientRect().height + 'px';
                if(width === 'auto') width = tempPopup.getBoundingClientRect().width + 'px';
                tempPopup.remove();
                if(ps[0] === 'center') {
                    popup.style.left = 'calc(50% - ' + parseInt(width)/2 + 'px)';
                    popup.style.top = 'calc(50% - ' + parseInt(height)/2 + 'px)';
                }
                else if(ps[0] === 'top' || ps[0] === 'bottom') {
                    if(ps[1] === 'center')
                        popup.style.left = 'calc(50% - ' + parseInt(width)/2 + 'px)';
                    else
                        popup.style[ps[1]] = '0';
                }
                else if(ps[0] === 'left' || ps[0] === 'right') {
                    if(ps[1] === 'center')
                        popup.style.top = 'calc(50% - ' + parseInt(height)/2 + 'px)';
                    else
                        popup.style[ps[1]] = '0';
                }
                resolve();
            }, 500);
        });
    } else {
        init = new Promise(function(resolve, reject) {
            if(ps[0] === 'center') {
                popup.style.left = 'calc(50% - ' + parseInt(width)/2 + 'px)';
                popup.style.top = 'calc(50% - ' + parseInt(height)/2 + 'px)';
            }
            else if(ps[0] === 'top' || ps[0] === 'bottom') {
                if(ps[1] === 'center')
                    popup.style.left = 'calc(50% - ' + parseInt(width)/2 + 'px)';
                else
                    popup.style[ps[1]] = '0';
            }
            else if(ps[0] === 'left' || ps[0] === 'right') {
                if(ps[1] === 'center')
                    popup.style.top = 'calc(50% - ' + parseInt(height)/2 + 'px)';
                else
                    popup.style[ps[1]] = '0';
            }
            resolve();
        });
    }
    popup.style[ps[0]] = '0';


    var overlayListenerAdded = false;

    var selfObject = {
        subscribe: function(subCallback) {
            subscriptionCallbacks.push(subCallback);
        },
        show: function(isPreview, custId, popupId, formId, callback) {
            if(callback)closeCallback = callback;
            var thisPopup = this;
            init.then(function() {
                if(status.open && !isPreview)
                    throw new Error('Popup is already shown');
                popup.style.transition = 'opacity ' + showDuration + ' ease 0s';
                if(overlayColor) {
                    overlay.style.transition = 'opacity ' + showDuration + ' ease 0s';
                    if(overlayLock!=='false')document.body.style.overflow = 'hidden';
                    document.body.insertBefore(overlay, document.body.firstElementChild);
                    overlay.appendChild(popup);
                    if(!scriptRun) {
                        Array.from(popup.querySelectorAll('script')).forEach(function(scriptTag) {
                            window.eval(scriptTag.innerHTML);
                            scriptRun = true;
                        });
                    }
                    if(overlayClick === 'close') {
                        if(!overlayListenerAdded) {
                            overlay.addEventListener('click', function() {
                                thisPopup.close();
                            });
                            overlayListenerAdded = true;
                        }
                    }
                } else {
                    popup.style.zIndex = maxInt;
                    document.body.insertBefore(popup, document.body.firstElementChild);
                    if(!scriptRun) {
                        Array.from(popup.querySelectorAll('script')).forEach(function(scriptTag) {
                            window.eval(scriptTag.innerHTML);
                            scriptRun = true;
                        });
                    }
                }
                setTimeout(async function(){
                    if(overlayColor) {
                        overlay.style.opacity = '1';
                    }
                    popup.style.opacity = '1';
                    for(element of Array.from(popup.getElementsByTagName('script'))) {
                        var scriptTag = await rvtsAddScript(element.src);
                        if(scriptTag)scriptTags.push(scriptTag);
                    }
                    status.open = true;
                    window['rvtsPopupAlreadyShown'] = true;
                    if(params.autoCloseDelay) {
                        closeTimeout = setTimeout(function() {
                            if(status.open)thisPopup.close();
                            closeTimeout = null;
                        }, parseDuration(showDuration) + parseDuration(params.autoCloseDelay));
                    }
                    if(subscriptionCallbacks.length>0) {
                        subscriptionCallbacks.forEach(c => {c.call(selfObject,true)});
                    }
                    if(!isPreview) {
                        saveLastPopupShow(popupId);
                        var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id='+formId+'&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
                        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                        fetchParams += '&url='+window.location.href;
                        fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                        document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) {
                            if(smartWidgetCallToActionButton) {
                                var activityType = smartWidgetCallToActionButton.getAttribute('activity_type');
                                if(activityType=='click')activityType='1';
                                else if(activityType=='submit')activityType='2';
                                smartWidgetCallToActionButton.addEventListener('click', function(){
                                    var fetchParams = '';
                                    fetchParams+= 'cust_id='+custId;
                                    fetchParams+='&popup_id='+popupId;
                                    fetchParams+='&form_id='+formId;
                                    fetchParams+='&user_agent='+navigator.userAgent;
                                    fetchParams+='&activity_type='+activityType;
                                    fetchParams+='&session_id='+rvtsSessionId;
                                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                                    fetchParams+='&url='+window.location.href;
                                    fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                                    if(activityType=='1')saveSwSource(popupId);
                                });
                            }
                        });
                        var iframeEvalString = "var rvtsUserId='"+rvtsUserId+"'; document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) { if(smartWidgetCallToActionButton) { var activityType = smartWidgetCallToActionButton.getAttribute('activity_type'); if(activityType=='click')activityType='1'; else if(activityType=='submit')activityType='2'; smartWidgetCallToActionButton.addEventListener('click', function(){ var fetchParams = ''; fetchParams+= 'cust_id="+custId+"'; fetchParams+='&popup_id="+popupId+"'; fetchParams+='&form_id="+formId+"';  fetchParams+='&user_agent='+navigator.userAgent; fetchParams+='&activity_type='+activityType; fetchParams+='&session_id="+rvtsSessionId+"'; if(rvtsUserId)fetchParams += '&user_id="+rvtsUserId+"'; fetchParams+='&url="+window.location.href+"'; fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);  }); } });"
                        if(iframe) {
                            var messageObject = {
                                swExecJSCode: true,
                                popupId: popupId,
                                JSCode: encodeURIComponent(iframeEvalString)
                            }
                            iframeLoaded.then(() => {
                                iframe.contentWindow.postMessage(messageObject, iframeLink);
                            });
                        }
                    }
                },250);
            });
        },
        close: close,
        isOpen: function() {
            return status.open;
        },
        getPopup: function() {
            return init.then(function() {
               return popup;
            });
        }
    }
    return selfObject;
}

function drawerPopup(params,widgetId) {
    var subscriptionCallbacks = [];
    var closeTimeout = null;
    
    var newStyleElement = document.createElement('style');
    newStyleElement.innerHTML = '@keyframes SWdrawerArrow1{0%{color: white;}50%{color: gray;}100%{color:white;}} @keyframes SWdrawerArrow2{0%{color: #d0d0d0;}50%{color:gray;}100%{color:#d0d0d0;}}';
    document.head.appendChild(newStyleElement);

    var scriptRun = false;
    var scriptTags = [];

    var init;
	
	var stateObj = (function () {
		var state = 1;
		return {toggle:function () {
			return ++state == 3 ? state = 1 : state;
		},
		get:function() {
			return state;
		}}
	})();
	
	var toggleState = stateObj.toggle;
	var getState = stateObj.get;
    
    if(params.drawerStartState === 'opened')toggleState();

    var tempTimeout = null;
    var close = function() {
        if(tempTimeout)return;
        if(!status.open)
            throw new Error('Popup is already hidden');
        popup.style.transition = ps[0] + ' ' + closeDuration + ' ease 0s';
        var s = styleToHide.split('|');
        popup.style[s[0]] = s[1];
        tempTimeout = setTimeout(function(){
            if(overlayColor) {
                popup.remove();
                overlay.remove();
                document.body.style.overflow = '';
            } else {
                popup.remove();
            }
            scriptTags.forEach(function(tag){tag.remove();});
            status.open = false;
            if(closeTimeout) {
                clearTimeout(closeTimeout);
                closeTimeout = null;
            }
            if(subscriptionCallbacks.length>0) {
                subscriptionCallbacks.forEach(c => {c.call(selfObject,false)});
            }
            tempTimeout = null;
        },parseDuration(closeDuration));
    }

    var status = {
        open: false
    }
    
    if(params.cssLinks) {
        params.cssLinks.split(',').forEach(function(element) {
            if(!rvtsSmartWidgetCssLinks.includes(element)) {
                var newLink = document.createElement('link');
                newLink.rel = 'stylesheet';
                newLink.type = 'text/css';
                newLink.href = element;
                document.head.appendChild(newLink);
                rvtsSmartWidgetCssLinks.push(element);
            }
        });
    }

    var showDuration = params.showDuration;
    var closeDuration = params.closeDuration;
    var height = params.height;
    var width = params.width;
	var previewSize = params.previewSize;
    var backgroundColor = params.backgroundColor;
    var overlayColor = params.overlayColor;
    var startPosition = params.startPosition // 'top left' || 'right bottom' etc.
    var vAlign = params.vAlign;
    var hAlign = params.hAlign;
    var html = params.html;
    var iframeLink = params.iframeLink;
    var overlayClick = params.overlayClick;
    var overlayLock = params.overlayLock;

    var overlay;

    if(overlayColor) {
        overlay = document.createElement('div')
        overlay.style.position = 'fixed';
        overlay.style.top = '0';
        overlay.style.left = '0';
        overlay.style.backgroundColor = overlayColor;
        overlay.style.zIndex = maxInt;
        overlay.style.height = '100vh';
        overlay.style.width = '100vw';
    }

    var ps = startPosition.split(' ');
	var orientation;
    var popup = document.createElement('div');
    popup.classList.add('smart-widget-container-div');
    var button = closeButton();
    var minButton = minimizeButton();
    var toggleButton = arrowButton();
    button.addEventListener('click', close);

    popup.style.backgroundColor = backgroundColor;
    popup.style.width = width;
    popup.style.height = height;
    popup.style.position = 'fixed';
    popup.style.display = 'flex';
    popup.style.alignItems = flexDirection[vAlign];
    popup.style.justifyContent = flexDirection[hAlign];
    popup.style.border = '1px solid #bbb';
    
	var iframe = null;
    var iframeResolver = null;
    var iframeLoaded = null;
    if(html) {
        popup.innerHTML = html;
    } else if(iframeLink) {
        iframeLoaded = new Promise((resolve,reject)=>{iframeResolver=resolve;});
        iframe = document.createElement('iframe');
        iframe.onload = function() {iframeResolver();}
        params.iframeClassName.split(' ').forEach(function(element) {
            if(element)iframe.classList.add(element);
        });
        iframe.setAttribute('src',iframeLink);
        if(width.slice(-2)!=='px')width+='px';
        if(height.slice(-2)!=='px')height+='px';
        iframe.style.setProperty('width',width === 'auto' ? '100%' : width,'important');
        iframe.style.setProperty('height',height === 'auto' ? '100%' : height,'important');
        iframe.setAttribute('scrolling','no');
        iframe.setAttribute('frameborder','0');
        popup.style.width = 'auto';
        popup.style.height = 'auto';
        width = 'auto';
        height = 'auto';
        popup.appendChild(iframe);
    }
    popup.appendChild(button);
    popup.appendChild(minButton);
    popup.appendChild(toggleButton.button);

    var styleToShow = '';
    var styleToHide = '';
	
	var value;

    if(height === 'auto' || width === 'auto') {
        var tempPopup = popup.cloneNode(true);
        tempPopup.style.visibility = 'hidden';
        document.body.insertBefore(tempPopup, document.body.firstElementChild);
        init = new Promise(function(resolve, reject) {
            setTimeout(function() {
                if(height === 'auto') height = tempPopup.getBoundingClientRect().height + 'px';
                if(width === 'auto') width = tempPopup.getBoundingClientRect().width + 'px';
                tempPopup.remove();
                if(ps[0] === 'top' || ps[0] === 'bottom') {
                    value = height;
                    if(ps[1] === 'center')
                        popup.style.left = 'calc(50% - ' + parseInt(width)/2 + 'px)';
                    else
                        popup.style[ps[1]] = '0';
                }
                else if(ps[0] === 'left' || ps[0] === 'right') {
                    value = width;
                    if(ps[1] === 'center')
                        popup.style.top = 'calc(50% - ' + parseInt(height)/2 + 'px)';
                    else
                        popup.style[ps[1]] = '0';
                }
				value = previewSize;
                popup.style[ps[0]] = '-' + value;

                styleToShow = ps[0] + '|0px';
                styleToHide = ps[0] + '|-' + value;
                resolve();
            }, 500);
        });
    } else {
        init = new Promise(function(resolve, reject) {
            if(ps[0] === 'top' || ps[0] === 'bottom') {
                value = height;
                if(ps[1] === 'center')
                    popup.style.left = 'calc(50% - ' + parseInt(width)/2 + 'px)';
                else
                    popup.style[ps[1]] = '0';
            }
            else if(ps[0] === 'left' || ps[0] === 'right') {
                value = width;
                if(ps[1] === 'center')
                    popup.style.top = 'calc(50% - ' + parseInt(height)/2 + 'px)';
                else
                    popup.style[ps[1]] = '0';
            }
			value = previewSize;
            popup.style[ps[0]] = '-' + value;

            styleToShow = ps[0] + '|0px';
            styleToHide = ps[0] + '|-' + value;
            resolve();
        });
    }
    
    var overlayListenerAdded = false;
    
    var show = function(isPreview, custId, popupId, formId) {
            var thisPopup = this;
            init.then(function() {
                if(status.open && !isPreview)
                    throw new Error('Popup is already shown');
                popup.style.transition = ps[0] + ' ' + showDuration + ' ease 0s';
				
				if(getState() === 1) {
                        button.style.display = 'none';
                        minButton.style.display = 'none';
                        toggleButton.button.style.display = 'block';
						popup.style[ps[0]] = '-' + previewSize;
						if(ps[0] === 'top' || ps[0] === 'bottom') {
                            if(ps[0] === 'top')
                                toggleButton.setPosition('bottom');
                            else if(ps[0] === 'bottom')
                                toggleButton.setPosition('top');
							if(iframe)
								iframe.setAttribute('height',previewSize);
							else
								popup.style.height = previewSize;
						} else {
                            if(ps[0] === 'left')
                                toggleButton.setPosition('right');
                            else if(ps[0] === 'right')
                                toggleButton.setPosition('left');
							if(iframe)
								iframe.setAttribute('width',previewSize);
							else
								popup.style.width = previewSize;
						}
                        styleToHide = ps[0] + '|-' + previewSize;
				} else if(getState() === 2) {
                    button.style.display = 'block';
                    minButton.style.display = 'block';
                    toggleButton.button.style.display = 'none';
					if(ps[0] === 'top' || ps[0] === 'bottom') {
                        if(ps[0] === 'top')
                            toggleButton.setPosition('bottom');
                        else if(ps[0] === 'bottom')
                            toggleButton.setPosition('top');
                        toggleButton.setArrow(ps[0]);
                        popup.style[ps[0]] = '-' + height;
                        styleToHide = ps[0] + '|-' + height;
						if(iframe)
							iframe.setAttribute('height',height);
						else
							popup.style.height = height;
					} else {
                        if(ps[0] === 'left')
                            toggleButton.setPosition('right');
                        else if(ps[0] === 'right')
                            toggleButton.setPosition('left');
                        toggleButton.setArrow(ps[0]);
                        popup.style[ps[0]] = '-' + width;
                        styleToHide = ps[0] + '|-' + width;
						if(iframe)
							iframe.setAttribute('width',width);
						else
							popup.style.width = width;
					}
				}
				
                if(overlayColor) {
                    if(overlayLock!=='false')document.body.style.overflow = 'hidden';
                    document.body.insertBefore(overlay, document.body.firstElementChild);
                    overlay.appendChild(popup);
                    if(!scriptRun) {
                        Array.from(popup.querySelectorAll('script')).forEach(function(scriptTag) {
                            window.eval(scriptTag.innerHTML);
                            scriptRun = true;
                        });
                    }
                    if(overlayClick === 'close') {
                        if(!overlayListenerAdded) {
                            overlay.addEventListener('click', function() {
                                thisPopup.close();
                            });
                            overlayListenerAdded = true;
                        }
                    }
                } else {
                    popup.style.zIndex = maxInt;
                    document.body.insertBefore(popup, document.body.firstElementChild);
                    if(!scriptRun) {
                        Array.from(popup.querySelectorAll('script')).forEach(function(scriptTag) {
                            window.eval(scriptTag.innerHTML);
                            scriptRun = true;
                        });
                    }
                }
                setTimeout(async function(){
				
                    var s = styleToShow.split('|');
                    popup.style[s[0]] = s[1];
                    for(element of Array.from(popup.getElementsByTagName('script'))) {
                        var scriptTag = await rvtsAddScript(element.src);
                        if(scriptTag)scriptTags.push(scriptTag);
                    }
                    status.open = true;
                    window['rvtsPopupAlreadyShown'] = true;
                    if(params.autoCloseDelay) {
                        closeTimeout = setTimeout(function() {
                            if(status.open)thisPopup.close();
                            closeTimeout = null;
                        }, parseDuration(showDuration) + parseDuration(params.autoCloseDelay));
                    }
                    if(subscriptionCallbacks.length>0) {
                        subscriptionCallbacks.forEach(c => {c.call(selfObject,true)});
                    }
                    if(!isPreview) {
                        saveLastPopupShow(popupId);
                        var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id='+formId+'&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
                        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                        fetchParams += '&url='+window.location.href;
                        fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                        document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) {
                            if(smartWidgetCallToActionButton) {
                                var activityType = smartWidgetCallToActionButton.getAttribute('activity_type');
                                if(activityType=='click')activityType='1';
                                else if(activityType=='submit')activityType='2';
                                smartWidgetCallToActionButton.addEventListener('click', function(){
                                    var fetchParams = '';
                                    fetchParams+= 'cust_id='+custId;
                                    fetchParams+='&popup_id='+popupId;
                                    fetchParams+='&form_id='+formId;
                                    fetchParams+='&user_agent='+navigator.userAgent;
                                    fetchParams+='&activity_type='+activityType;
                                    fetchParams+='&session_id='+rvtsSessionId;
                                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                                    fetchParams+='&url='+window.location.href;
                                    fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                                    if(activityType=='1')saveSwSource(popupId);
                                });
                            }
                        });
                        var iframeEvalString = "var rvtsUserId='"+rvtsUserId+"'; document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) { if(smartWidgetCallToActionButton) { var activityType = smartWidgetCallToActionButton.getAttribute('activity_type'); if(activityType=='click')activityType='1'; else if(activityType=='submit')activityType='2'; smartWidgetCallToActionButton.addEventListener('click', function(){ var fetchParams = ''; fetchParams+= 'cust_id="+custId+"'; fetchParams+='&popup_id="+popupId+"'; fetchParams+='&form_id="+formId+"';  fetchParams+='&user_agent='+navigator.userAgent; fetchParams+='&activity_type='+activityType; fetchParams+='&session_id="+rvtsSessionId+"'; if(rvtsUserId)fetchParams += '&user_id="+rvtsUserId+"'; fetchParams+='&url="+window.location.href+"'; fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);  }); } });"
                        if(iframe) {
                            var messageObject = {
                                swExecJSCode: true,
                                popupId: popupId,
                                JSCode: encodeURIComponent(iframeEvalString)
                            }
                            iframeLoaded.then(() => {
                                iframe.contentWindow.postMessage(messageObject, iframeLink);
                            });
                        }
                    }
                },250);
            });
        }
    
    toggleButton.button.addEventListener('click', function() {
        close();
        toggleState();
        setTimeout(function(){show();},parseDuration(closeDuration));
    });
    
    minButton.addEventListener('click', function() {
        close();
        toggleState();
        setTimeout(function(){show();},parseDuration(closeDuration));
    });

    var selfObject = {
        subscribe: function(subCallback) {
            subscriptionCallbacks.push(subCallback);
        },
        show: show,
        close: close,
        isOpen: function() {
            return status.open;
        },
        getPopup: function() {
            return init.then(function() {
               return popup;
            });
        }
    }
    return selfObject;
}

function rvtsProductAlert(params, popupId,custId) {
    var settings = params.productAlertSettings;
    var querySelector = settings.querySelector ? settings.querySelector : '.rvts_product_alert';
    var selectedElement = document.querySelector(querySelector);
    if(!selectedElement)return;
    var currentProduct = (typeof rvtsSWCurrentProduct !== 'undefined') ? rvtsSWCurrentProduct : null;
    var productStockCount = currentProduct ? currentProduct.stockCount : null;
    if(productStockCount==0)return;
    var productIdList = settings.productIdList.map(e=>decodeURIComponent(e).toLocaleLowerCase().trim());
    var productNameList = settings.productNameList.map(e=>decodeURIComponent(e).toLocaleLowerCase().trim());
    var productNameExcludeList = settings.productNameExcludeList.map(e=>decodeURIComponent(e).toLocaleLowerCase().trim());
    productIdList = productIdList.filter(e=>e);
    productNameList = productNameList.filter(e=>e);
    productNameExcludeList = productNameExcludeList.filter(e=>e);
    var productId = currentProduct ? currentProduct.p_id.toLocaleLowerCase() : null;
    var productName = currentProduct ? currentProduct.name.toLocaleLowerCase() : window.location.href;
    var productIdMatch = false;
    var productNameMatch = false;
    var productNameExcludeMatch = false;
    productNameExcludeList.forEach(name => {
        if(productName.includes(name)) {
            productNameExcludeMatch = true;
        }
    });
    if(productNameExcludeList.length>0 && productNameExcludeMatch)return;
    if(productId) {
        productIdList.forEach(id => {
            if(productId == id)productIdMatch = true;
        });
    } else {
        productIdMatch = true;
    }
    productNameList.forEach(name => {
        if(productName.includes(name)) {
            productNameMatch = true;
        }
    });
    if(productIdList.length===0)productIdMatch=true;
    if(productNameList.length===0)productNameMatch=true;
    if(!productIdMatch && productNameList.length===0)return;
    if(!productNameMatch && productIdList.length===0)return;
    if(!productIdMatch && !productNameMatch)return;
    var contentDiv = document.createElement('div');
    var content = document.createElement('div');
    if(productStockCount && (parseInt(productStockCount)<parseInt(settings.stockCount))) {
        content.innerHTML = decodeURIComponent(settings.content).replace('[STOCK-COUNT]', productStockCount);
    } else {
        content.innerHTML = decodeURIComponent(settings.content).replace('[STOCK-COUNT]', settings.stockWord);
    }
    contentDiv.appendChild(content);
    selectedElement.innerHTML = '';
    selectedElement.appendChild(contentDiv);
    if(settings.showProgressBar && productStockCount && (parseInt(productStockCount)<parseInt(settings.stockCount))) {
        var maxBarWidth = content.getBoundingClientRect().width;
        if(maxBarWidth>300)maxBarWidth=300;
        var progressBG = null;
        var progressFill = null;
        var percentage = Math.round((parseInt(productStockCount) / parseInt(settings.stockCount)) * 100);
        var fillWidth = Math.round((maxBarWidth * percentage) / 100);
        var progressBar = document.createElement('div');
        progressBar.innerHTML = '<div id="progressBG" style="transition:width 1s;margin-top:10px; width: 0;height: 10px;background-color: '+settings.progressBGColor+';border-radius: 10px;"><div id="progressFill" style="transition:width 1s;position: absolute;width: 0;height: 10px;background-color: '+settings.progressFillColor+';border-radius: 10px;"></div></div>';
        progressBG = progressBar.firstElementChild;
        progressFill = progressBG.firstElementChild
        contentDiv.appendChild(progressBar);
        if(document.readyState === 'complete') {
            setTimeout(function(){progressBG.style.width = maxBarWidth + 'px';},1);
            setTimeout(function(){progressFill.style.width = fillWidth + 'px';},250);
        } else {
            window.addEventListener('load', () => {
                setTimeout(function(){progressBG.style.width = maxBarWidth + 'px';},1);
                setTimeout(function(){progressFill.style.width = fillWidth + 'px';},250);
            });
        }
    }
    var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id=0&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
    fetchParams += '&url='+window.location.href;
    fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
    
    return contentDiv;
}

async function rvtsSocialProof(params,popupId,custId,rcpLink,isPreview) {
    var proofType = null;
    var recoFetched = false;
    var swParams = Object.assign({}, params);
    var scpSettings = params.socialProofSettings;
    var HTML = '<div>'+decodeURIComponent(scpSettings.content)+'</div>';
    var currentProduct = null;
    var recoType = {
        50: '[TOP_SELLER_PRODUCT]',
        60: '[PRICE_DROP_PRODUCT]',
        70: '[NEW_ARRIVAL_PRODUCT]'
    }
    for(var objKey in recoType) {
        if(HTML.includes(recoType[objKey])) {
            var product = await fetch('https://'+ rcpLink +'/rrcp/imc/recommendation/get_recommendation.jsp?cust_id='+custId+'&type='+objKey+'&limit=50').then(resp=>resp.json()).then(resp => {
                var maxNum = resp.length - 1;
                var randNumber = Math.floor(Math.random() * (maxNum + 1));
                return resp[randNumber][0];
            }).catch(e => {});
            if(product) {
                currentProduct = product;
                var tempURL = new URL(product.link);
                var tempLink = product.link;
                if(tempURL.search)tempLink+='&';
                else tempLink+='?';
                tempLink+='utm_source=revotas&utm_medium=sw&utm_campaign=socialproof'
                HTML = HTML.split(recoType[objKey]).join('<a style="color:inherit;" href="'+tempLink+'">'+product.name+'</a>');
                recoFetched = true;
                proofType = objKey;
            } else {
                return;
            }
            break;
        }
    }
    if(!currentProduct)currentProduct = (typeof rvtsSWCurrentProduct !== 'undefined') ? rvtsSWCurrentProduct : null;
    var productId = currentProduct ? currentProduct.p_id.toString().toLocaleLowerCase() : null;
    var productName = currentProduct ? currentProduct.name.toLocaleLowerCase() : window.location.href;
    var productIdList = scpSettings.productIdList.map(e=>decodeURIComponent(e).toLocaleLowerCase().trim());
    var productNameList = scpSettings.productNameList.map(e=>decodeURIComponent(e).toLocaleLowerCase().trim());
    var productNameExcludeList = scpSettings.productNameExcludeList.map(e=>decodeURIComponent(e).toLocaleLowerCase().trim());
    productIdList = productIdList.filter(e=>e);
    productNameList = productNameList.filter(e=>e);
    productNameExcludeList = productNameExcludeList.filter(e=>e);
    var productIdMatch = false;
    var productNameMatch = false;
    var productNameExcludeMatch = false;
    productNameExcludeList.forEach(name => {
        if(productName.includes(name)) {
            productNameExcludeMatch = true;
        }
    });
    if(productNameExcludeList.length>0 && productNameExcludeMatch)return;
    if(productId) {
        productIdList.forEach(id => {
            if(productId == id)productIdMatch = true;
        });
    } else {
        productIdMatch = true;
    }
    productNameList.forEach(name => {
        if(productName.includes(name)) {
            productNameMatch = true;
        }
    });
    if(productIdList.length===0)productIdMatch=true;
    if(productNameList.length===0)productNameMatch=true;
    if(!productIdMatch && productNameList.length===0)return;
    if(!productNameMatch && productIdList.length===0)return;
    if(!productIdMatch && !productNameMatch)return;
    
    var ipAddress = null;
    var locationObj = null;
    var locationEnabled = false;
    
    if(!isPreview || currentProduct || scpSettings.pageViewReferrer) {
        if(HTML.includes('[TOTAL_ORDER]') && scpSettings.randomizeTotalOrder == 0) { //Fetch order count
            if(!recoFetched)proofType = 'order';
            if(!productId)return;
            var orderCount = await fetch('https://'+ rcpLink + '/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id='+custId+'&type=order&product_id='+productId).then(resp=>resp.text()).then(resp=>resp.trim());
            if(orderCount>0)
                HTML = HTML.split('[TOTAL_ORDER]').join(orderCount);
            else {
                var orderCountMax = parseInt(scpSettings.orderCountMax);
                var orderCountMin = parseInt(scpSettings.orderCountMin);
                var randNumber = Math.floor(Math.random() * (orderCountMax - orderCountMin + 1)) + orderCountMin;
                var storageObject = localStorage.getItem('rvts_total_order');
                if(storageObject) {
                    storageObject = JSON.parse(storageObject);
                    var now = new Date();
                    now.setHours(0,0,0,0);
                    var backupDate = new Date(storageObject.date);
                    backupDate.setHours(0,0,0,0);
                    var dayDiff = Math.round((now.getTime() - backupDate.getTime()) / (1000*60*60*24));
                    if(dayDiff == 0 && !recoFetched)
                        randNumber = storageObject.number + (Math.floor(Math.random() * (10)) == 1 ? 1 : 0);
                }
                HTML = HTML.split('[TOTAL_ORDER]').join(randNumber);
                localStorage.setItem('rvts_total_order', JSON.stringify({number: randNumber, date: new Date()}));
            }

        } else if(HTML.includes('[TOTAL_ORDER]') && scpSettings.randomizeTotalOrder == 1) { //Randomize order count
            if(!recoFetched)proofType = 'order';
            if(!productId)return;
            var orderCountMax = parseInt(scpSettings.orderCountMax);
            var orderCountMin = parseInt(scpSettings.orderCountMin);
            var randNumber = Math.floor(Math.random() * (orderCountMax - orderCountMin + 1)) + orderCountMin;
            var storageObject = localStorage.getItem('rvts_total_order');
            if(storageObject) {
                storageObject = JSON.parse(storageObject);
                var now = new Date();
                now.setHours(0,0,0,0);
                var backupDate = new Date(storageObject.date);
                backupDate.setHours(0,0,0,0);
                var dayDiff = Math.round((now.getTime() - backupDate.getTime()) / (1000*60*60*24));
                if(dayDiff == 0 && !recoFetched)
                    randNumber = storageObject.number + (Math.floor(Math.random() * (10)) == 1 ? 1 : 0);
            }
            HTML = HTML.split('[TOTAL_ORDER]').join(randNumber);
            localStorage.setItem('rvts_total_order', JSON.stringify({number: randNumber, date: new Date()}));
        }
        if(HTML.includes('[TOTAL_CART]') && scpSettings.randomizeTotalCart == 0) { //Fetch cart count
            if(!recoFetched)proofType = 'cart';
            if(!productId)return;
            var cartCount = await fetch('https://'+ rcpLink + '/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id='+custId+'&type=cart&product_id='+productId).then(resp=>resp.text()).then(resp=>resp.trim());
            if(cartCount>0)
                HTML = HTML.split('[TOTAL_CART]').join(cartCount);
            else {
                var cartCountMax = parseInt(scpSettings.cartCountMax);
                var cartCountMin = parseInt(scpSettings.cartCountMin);
                var randNumber = Math.floor(Math.random() * (cartCountMax - cartCountMin + 1)) + cartCountMin;
                var storageObject = localStorage.getItem('rvts_total_cart');
                if(storageObject) {
                    storageObject = JSON.parse(storageObject);
                    var now = new Date();
                    now.setHours(0,0,0,0);
                    var backupDate = new Date(storageObject.date);
                    backupDate.setHours(0,0,0,0);
                    var dayDiff = Math.round((now.getTime() - backupDate.getTime()) / (1000*60*60*24));
                    if(dayDiff == 0 && !recoFetched)
                        randNumber = storageObject.number + (Math.floor(Math.random() * (10)) == 1 ? 1 : 0);
                }
                HTML = HTML.split('[TOTAL_CART]').join(randNumber);
                localStorage.setItem('rvts_total_cart', JSON.stringify({number: randNumber, date: new Date()}));
            }
        } else if(HTML.includes('[TOTAL_CART]') && scpSettings.randomizeTotalCart == 1) { //Randomize cart count
            if(!recoFetched)proofType = 'cart';
            if(!productId)return;
            var cartCountMax = parseInt(scpSettings.cartCountMax);
            var cartCountMin = parseInt(scpSettings.cartCountMin);
            var randNumber = Math.floor(Math.random() * (cartCountMax - cartCountMin + 1)) + cartCountMin;
            var storageObject = localStorage.getItem('rvts_total_cart');
            if(storageObject) {
                storageObject = JSON.parse(storageObject);
                var now = new Date();
                now.setHours(0,0,0,0);
                var backupDate = new Date(storageObject.date);
                backupDate.setHours(0,0,0,0);
                var dayDiff = Math.round((now.getTime() - backupDate.getTime()) / (1000*60*60*24));
                if(dayDiff == 0 && !recoFetched)
                    randNumber = storageObject.number + (Math.floor(Math.random() * (10)) == 1 ? 1 : 0);
            }
            HTML = HTML.split('[TOTAL_CART]').join(randNumber);
            localStorage.setItem('rvts_total_cart', JSON.stringify({number: randNumber, date: new Date()}));
        }
        if(HTML.includes('[TOTAL_PAGE_VIEW]') && scpSettings.randomizeTotalPageView == 0) { //Fetch page view count
            if(!recoFetched)proofType = 'pageview';
            var pageViewCount = await fetch('https://'+ rcpLink + '/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id='+custId+'&type=pageView&ref_link='+(scpSettings.pageViewReferrer ? scpSettings.pageViewReferrer : window.location.href)).then(resp=>resp.text()).then(resp=>resp.trim());
            if(pageViewCount>0)
                HTML = HTML.split('[TOTAL_PAGE_VIEW]').join(pageViewCount);
            else {
                var pageViewCountMax = parseInt(scpSettings.pageViewCountMax);
                var pageViewCountMin = parseInt(scpSettings.pageViewCountMin);
                var randNumber = Math.floor(Math.random() * (pageViewCountMax - pageViewCountMin + 1)) + pageViewCountMin;
                var storageObject = localStorage.getItem('rvts_total_page_view');
                if(storageObject) {
                    storageObject = JSON.parse(storageObject);
                    var now = new Date();
                    now.setHours(0,0,0,0);
                    var backupDate = new Date(storageObject.date);
                    backupDate.setHours(0,0,0,0);
                    var dayDiff = Math.round((now.getTime() - backupDate.getTime()) / (1000*60*60*24));
                    if(dayDiff == 0)
                        randNumber = storageObject.number + (scpSettings.pageViewReferrer ? (Math.floor(Math.random() * (5)) == 1 ? 1 : 0) : 1);
                }
                HTML = HTML.split('[TOTAL_PAGE_VIEW]').join(randNumber);
                localStorage.setItem('rvts_total_page_view', JSON.stringify({number: randNumber, date: new Date()}));
            }
        } else if(HTML.includes('[TOTAL_PAGE_VIEW]') && scpSettings.randomizeTotalPageView == 1) { //Randomize page view
            if(!recoFetched)proofType = 'pageview';
            var pageViewCountMax = parseInt(scpSettings.pageViewCountMax);
            var pageViewCountMin = parseInt(scpSettings.pageViewCountMin);
            var randNumber = Math.floor(Math.random() * (pageViewCountMax - pageViewCountMin + 1)) + pageViewCountMin;
            var storageObject = localStorage.getItem('rvts_total_page_view');
            if(storageObject) {
                storageObject = JSON.parse(storageObject);
                var now = new Date();
                now.setHours(0,0,0,0);
                var backupDate = new Date(storageObject.date);
                backupDate.setHours(0,0,0,0);
                var dayDiff = Math.round((now.getTime() - backupDate.getTime()) / (1000*60*60*24));
                if(dayDiff == 0)
                    randNumber = storageObject.number + (scpSettings.pageViewReferrer ? (Math.floor(Math.random() * (5)) == 1 ? 1 : 0) : 1);
            }
            HTML = HTML.split('[TOTAL_PAGE_VIEW]').join(randNumber);
            localStorage.setItem('rvts_total_page_view', JSON.stringify({number: randNumber, date: new Date()}));
        }
        if(HTML.includes('[TOTAL_PRODUCT_VIEW]')) {
            if(!recoFetched)proofType = 'productview';
            if(!productId)return;
            var productViewCountMax = parseInt(scpSettings.productViewCountMax);
            var productViewCountMin = parseInt(scpSettings.productViewCountMin);
            var randNumber = Math.floor(Math.random() * (productViewCountMax - productViewCountMin + 1)) + productViewCountMin;
            var storageObject = localStorage.getItem('rvts_total_product_view');
            if(storageObject) {
                storageObject = JSON.parse(storageObject);
                var now = new Date();
                now.setHours(0,0,0,0);
                var backupDate = new Date(storageObject.date);
                backupDate.setHours(0,0,0,0);
                var dayDiff = Math.round((now.getTime() - backupDate.getTime()) / (1000*60*60*24));
                if(dayDiff == 0 && !recoFetched)
                    randNumber = storageObject.number + 1;
            }
            HTML = HTML.split('[TOTAL_PRODUCT_VIEW]').join(randNumber);
            localStorage.setItem('rvts_total_product_view', JSON.stringify({number: randNumber, date: new Date()}));
        }
        if(HTML.includes('[LAST_ORDER_CITY]')) {
            locationEnabled = true;
            if(typeof google === 'undefined' ||  typeof google.maps.Map !== 'function') {
                var gMapScript = document.createElement('script');
                gMapScript.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyBBHNs9s-KkjJcBb0Q75TpqnrXZde63_28&callback=rvtsSocialProofInitMap';
                document.head.appendChild(gMapScript);
                await rvtsMapInitialized;
            }
            ipAddress = await fetch('https://'+rcpLink+'/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id='+custId+'&type=ipList').then(resp=>resp.json()).then(resp=>{
                var maxNum = resp.length - 1;
                var randNumber = Math.floor(Math.random() * (maxNum + 1));
                return resp[randNumber];
            });
            locationObj = await fetch('https://pro.ip-api.com/json/'+ipAddress+'?key=meqxcbbXZfQRbIa').then(resp=>resp.json()).then(resp=>{
                return {
                    lng: resp.lon,
                    lat: resp.lat,
                    city: resp.city
                }    
            });
            HTML = HTML.split('[LAST_ORDER_CITY]').join(locationObj.city);
        }
    } else {
        if(HTML.includes('[LAST_ORDER_CITY]')) {
            locationEnabled = true;
            if(typeof google === 'undefined' ||  typeof google.maps.Map !== 'function') {
                var gMapScript = document.createElement('script');
                gMapScript.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyBBHNs9s-KkjJcBb0Q75TpqnrXZde63_28&callback=rvtsSocialProofInitMap';
                document.head.appendChild(gMapScript);
                await rvtsMapInitialized;
            }
            ipAddress = await fetch('https://'+rcpLink+'/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id='+custId+'&type=ipList').then(resp=>resp.json()).then(resp=>{
                var maxNum = resp.length - 1;
                var randNumber = Math.floor(Math.random() * (maxNum + 1));
                return resp[randNumber];
            });
            locationObj = await fetch('https://pro.ip-api.com/json/'+ipAddress+'?key=meqxcbbXZfQRbIa').then(resp=>resp.json()).then(resp=>{
                return {
                    lng: resp.lon,
                    lat: resp.lat,
                    city: resp.city
                }    
            });
            HTML = HTML.split('[LAST_ORDER_CITY]').join(locationObj.city);
        }
        if(HTML.includes('[TOTAL_ORDER]'))proofType='order';
        if(HTML.includes('[TOTAL_CART]'))proofType='cart';
        if(HTML.includes('[TOTAL_PAGE_VIEW]'))proofType='pageview';
        if(HTML.includes('[TOTAL_PRODUCT_VIEW]'))proofType='productview';
        HTML = HTML.split('[TOTAL_ORDER]').join(50);
        HTML = HTML.split('[TOTAL_PAGE_VIEW]').join(50);
        HTML = HTML.split('[TOTAL_PRODUCT_VIEW]').join(50);
        HTML = HTML.split('[TOTAL_CART]').join(50);
    }
    
    var smallSize = {
        width: '220px',
        height: '60px',
        width2: '35px',
        height2: '35px',
        width3: '22px',
        height3: '22px',
        height4: '60px',
        width4: '60px',
    }
    var mediumSize = {
        width: '280px',
        height: '70px',
        width2: '45px',
        height2: '45px',
        width3: '30px',
        height3: '30px',
        height4: '68px',
        width4: '68px',
    }
    var largeSize = {
        width: '330px',
        height: '85px',
        width2: '55px',
        height2: '55px',
        width3: '35px',
        height3: '35px',
        height4: '84px',
        width4: '84px',
    }
    var sizeArr = [smallSize,mediumSize,largeSize];
    var w = sizeArr[scpSettings.widgetSize].width;
    var h = sizeArr[scpSettings.widgetSize].height;
    var w2 = sizeArr[scpSettings.widgetSize].width2;
    var h2 = sizeArr[scpSettings.widgetSize].height2;
    var w3 = sizeArr[scpSettings.widgetSize].width3;
    var h3 = sizeArr[scpSettings.widgetSize].height3;
    if(locationEnabled) {
        var w2 = sizeArr[scpSettings.widgetSize].width4;
        var h2 = sizeArr[scpSettings.widgetSize].height4;
    }
    var defaultPicture = 'https://l.revotas.com/trc/smartwidget/flame.png';
    var bgColor = '#ff6600';
    if(proofType==50) {
        defaultPicture = 'https://l.revotas.com/trc/smartwidget/top-seller-product.png';
        var bgColor = '#fff';
    } else if(proofType==60) {
        defaultPicture = 'https://l.revotas.com/trc/smartwidget/price-drop-product.png';
        var bgColor = '#fff';
    } else if(proofType==70) {
        defaultPicture = 'https://l.revotas.com/trc/smartwidget/new-arrival-product.png';
        var bgColor = '#fff';
    } else if(proofType=='order') {
        defaultPicture = 'https://l.revotas.com/trc/smartwidget/total-order.png';
        var bgColor = '#fff';
    } else if(proofType=='cart') {
        defaultPicture = 'https://l.revotas.com/trc/smartwidget/total-cart.png';
        var bgColor = '#fff';
    } else if(proofType=='pageview') {
        defaultPicture = 'https://l.revotas.com/trc/smartwidget/total-page-view.png';
        var bgColor = '#fff';
    } else if(proofType=='productview') {
        defaultPicture = 'https://l.revotas.com/trc/smartwidget/product-view.png';
        var bgColor = '#fff';
    }
    var socialProofHTML = '<style> .social-proof-container:hover + div { display: unset !important; } .social-proof-container + div:hover { display: unset !important; } .social-proof-container { margin: 15px; display: flex; align-items: center; justify-content: center; flex-direction: row; width: '+w+'; height: '+h+'; border: 2px solid #d6d6d6; background: white; -moz-border-radius: 400px ; -webkit-border-radius: 400px; border-radius: 400px; } .social-proof-icon { display: flex; align-items: center; justify-content: center; background-color: '+(bgColor)+'; border: 3px solid #d6d6d6; height:'+h2+'; width:'+w2+'; -moz-border-radius:40px; -webkit-border-radius: 40px; border-radius: 40px; color: #fff; } .social-proof-icon a {display:none;} .social-proof-icon a img {display:none;} .social-proof-icon > img { height:'+h3+'; width:'+w3+'; } .social-proof-text { display: flex; align-items: center; justify-content: center; } </style> <meta charset="utf-8"> <div class="social-proof-container"> <div class="social-proof-icon"> <img src="'+(defaultPicture)+'"> </div> <div class="social-proof-text" style="width:70%;padding-left:10px;">'+HTML+'</div> </div>';
    swParams.type = scpSettings.animationType;
    swParams.height = 'auto';
    swParams.width = 'auto';
    swParams.backgroundColor = scpSettings.backgroundColor;
    swParams.hAlign = 'center';
    swParams.vAlign = 'center';
    swParams.autoCloseDelay = scpSettings.autoCloseDelay;
    swParams.showDuration = scpSettings.showDuration;
    swParams.closeDuration = scpSettings.closeDuration;
    swParams.contentType = 'htmlCode';
    swParams.html = socialProofHTML;
    if(swParams.type === 'sliding') {
        swParams.startPosition = scpSettings.startPosition;
        swParams.endPosition = scpSettings.endPosition;
    } else if(swParams.type === 'fading') {
        swParams.position = scpSettings.position;
    }
    delete swParams['socialProofSettings'];
    var customButton = document.createElement('div');
    customButton.style.fontSize = '10px';
    customButton.style.color= '#adadad';
    customButton.style.position = 'absolute';
    customButton.style.fontFamily = 'sans-serif';
    customButton.style.top = '27px';
    customButton.style.right = '35px';
    customButton.style.fontWeight = '700';
    customButton.style.cursor= 'pointer';
    customButton.innerHTML = 'X';
    customButton.style.display = 'none';
    var popup = null;
    if(swParams.type === 'sliding')
        popup = slidingPopup(swParams,popupId,customButton);
    else if(swParams.type === 'fading')
        popup = fadingPopup(swParams,popupId,customButton);
    if(locationEnabled) {
        await popup.getPopup().then(popupDiv => {
            popupDiv.querySelector('.social-proof-icon').innerHTML = '';
            var map = new google.maps.Map(popupDiv.querySelector('.social-proof-icon'), {
                center: { lat:locationObj.lat, lng: locationObj.lng },
                scrollwheel: false,
                zoom: 10,
                draggable: false,
                disableDefaultUI: true,
                clickableIcons:false
            });
        });
    }
    if(!isPreview) {
        popup.getPopup().then(popupDiv => {
            Array.from(popupDiv.querySelectorAll('a')).forEach(link => {
                link.addEventListener('click', function() {
                    var fetchParams = '';
                    fetchParams+= 'cust_id='+custId;
                    fetchParams+='&popup_id='+popupId;
                    fetchParams+='&form_id=0';
                    fetchParams+='&user_agent='+navigator.userAgent;
                    fetchParams+='&activity_type=1';
                    fetchParams+='&session_id='+rvtsSessionId;
                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                    fetchParams+='&url='+window.location.href;
                    fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                    if(activityType=='1')saveSwSource(popupId);
                });
            });
        })
    }
    return popup;
}

async function rvtsPopup(params, isPreview, custId, popupId, formId, rcpLink, isLivePreview) {
    var popup;
    if(params.type === 'sticky') {
        popup = stickyPopup(params,popupId);
    } else if(params.type === 'sliding') {
        popup = slidingPopup(params,popupId);
    } else if(params.type === 'fading') {
        popup = fadingPopup(params,popupId);
    } else if(params.type === 'drawer') {
        popup = drawerPopup(params,popupId);
    } else if(params.type === 'productAlert') {
        if(params.scriptCode)window.eval(params.scriptCode);
        rvtsProductAlert(params,popupId,custId);
    } else if(params.type === 'socialProof') {
        var initialDelay = params.socialProofSettings.initialDelay;
        var showInLoop = params.socialProofSettings.showInLoop;
        var loopInterval = params.socialProofSettings.loopInterval;
        if(!isPreview && params.scriptCode)window.eval(params.scriptCode);
        popup = await rvtsSocialProof(params,popupId,custId,rcpLink,isPreview);
        if(!popup)return;
        if(!isPreview) {
            setTimeout(function() {
                if(showInLoop == 1) {
                    var loopFunction = () => {
                        setTimeout(function() {
                            if(!isLivePreview)popup.show(false, custId, popupId, formId, loopFunction);
                            else popup.show(true,null,null,null,loopFunction);
                        },parseDuration(loopInterval));
                    }
                    if(!isLivePreview)popup.show(false, custId, popupId, formId, loopFunction);
                    else popup.show(true,null,null,null,loopFunction);
                } else {
                    if(!isLivePreview)popup.show(false, custId, popupId, formId);
                    else popup.show(true);
                }
            },parseDuration(initialDelay));
        }
        return popup;
    }
    if(!window['rvtsSmartWidgetList'])
        window['rvtsSmartWidgetList'] = {};
    if(popup) {
        window['rvtsSmartWidgetList'][popupId] = popup;
        window['rvtsSmartWidgetList'][popupId].custId = custId;
        window['rvtsSmartWidgetList'][popupId].popupId = popupId;
        window['rvtsSmartWidgetList'][popupId].formId = formId;
    }
    if(!isPreview) {
        if(params.trigger === 'scroll') {
        var scrollEvent = function() {
            if(getScrollPercent() >= params.scrollPercentage) {
                if(popup){
                    if(!isLivePreview)popup.show(false, custId, popupId, formId);
                    else popup.show(true);
                }
                document.removeEventListener('scroll', scrollEvent);
                if(params.scriptCode)eval('(function(){'+params.scriptCode+'}).call(popup);');
            }
        }
        document.addEventListener('scroll', scrollEvent)
        } else if(params.trigger === 'mouseLeave') {
            var leaveEvent = function() {
                if(popup){
                    if(!isLivePreview)popup.show(false, custId, popupId, formId);
                    else popup.show(true);
                }
                document.removeEventListener('mouseleave', leaveEvent);
                if(params.scriptCode)eval('(function(){'+params.scriptCode+'}).call(popup);');
            }
            setTimeout(function() {
                document.addEventListener('mouseleave', leaveEvent);
            }, 2000);
        } else if(params.trigger === 'afterLoad') {
            var run = function() {
                function runAfterLoad(){
                    if(popup){
                        if(!isLivePreview)popup.show(false, custId, popupId, formId);
                        else popup.show(true);
                    }
                    if(params.scriptCode)eval('(function(){'+params.scriptCode+'}).call(popup);');
                }
                if(parseDuration(params.delay)==0)runAfterLoad();
                else setTimeout(runAfterLoad,parseDuration(params.delay));
            }
            if (document.readyState !== 'loading') run();
            else document.addEventListener('DOMContentLoaded', run);
        }
    }
    return popup;
}

__smartWidgetConditionFunctions__.deviceType = function deviceType(type) {
	var agent = navigator.userAgent.toLowerCase();
	if(type === 'mobile') {
		if(agent.includes('iphone') || agent.includes('android'))
			return true;
	} else if(type === 'desktop') {
		if(!agent.includes('iphone') && !agent.includes('android'))
			return true;
	}
    return false;
}

__smartWidgetConditionFunctions__.pageUrl = function pageUrl(operator, url) {
	var currentUrl = window.location.href.toLowerCase();
	if(operator === 'is') {
		return currentUrl === url.toLowerCase();
	} else if(operator === 'isnot') {
		return currentUrl !== url.toLowerCase();
	} else if(operator === 'includes') {
		return currentUrl.includes(url.toLowerCase());
	} else if(operator === 'notincludes') {
		return !currentUrl.includes(url.toLowerCase());
	}
}

__smartWidgetConditionFunctions__.pageUrlVisited = function pageUrlVisited(operator, url) {
    var cname = 'rvts_user_history_array';
    var storageVisitHistory = localStorage.getItem(cname);
    if(storageVisitHistory) {
        var historyArray = storageVisitHistory.split('|');
        var tempArray = historyArray.filter(function(element) {
            if(operator === 'is') {
                return element === url.toLowerCase();
            } else if(operator === 'isnot') {
                return element !== url.toLowerCase();
            } else if(operator === 'includes') {
                return element.includes(url.toLowerCase());
            } else if(operator === 'notincludes') {
                return !element.includes(url.toLowerCase());
            }
        });
        if(operator === 'is' || operator === 'includes')
            return tempArray.length === 0 ? false : true;
        else if(operator === 'isnot' || operator === 'notincludes')
            return tempArray.length !== historyArray.length ? false : true;
    }
    return false;
}

__smartWidgetConditionFunctions__.timeSpent = function timeSpent(type,time) {
    var cname = 'rvts_user_browse_time';
    var cookieTimeSpent = swGetCookie(cname);
    if(cookieTimeSpent) {
        if(cookieTimeSpent >= time * (type==='minutes'?60:1)) {
            swSetCookie(cname,'0',10,hname);
            return true;
        }
        else
            return false;
    }
    return false;
}

__smartWidgetConditionFunctions__.lastPopupShow = function lastPopupShow(days, pagesObj, popupId) {
    var cname = 'rvts_popup_last_show';
    var cookieLastShow = swGetCookie(cname);
    if(cookieLastShow) {
        try {
            obj = JSON.parse(cookieLastShow);
            if(!obj[popupId])
                return true;
            var cookieDate = new Date(obj[popupId]);
            cookieDate.setHours(23,59,59,999);
            var cDate = new Date();
            cDate.setHours(23,59,59,999);
            var dayDiff = Math.ceil((cDate-cookieDate) / (1000 * 60 * 60 * 24));
            if(dayDiff >= days)
                return true;
            else
                return false;
        } catch(e) {
            return true;
        }
    }
    return true;
}

__smartWidgetConditionFunctions__.firstVisit = function firstVisit() {
    var cname = 'rvts_user_first_visit';
    if(swGetCookie(cname)) {
        return false;
    } else {
        swSetCookie(cname,'0',1000,hname);
        return true;
    }
}

__smartWidgetConditionFunctions__.isMember = function isMember(is, pagesObj) {
    var currentUrl = window.location.href.toLowerCase();
    var registerPage = pagesObj.registerPage;
    var cname = 'rvts_is_member';
    var cookieIsMember = swGetCookie(cname);
    var pageUrlVisited = __smartWidgetConditionFunctions__.pageUrlVisited;
    if(cookieIsMember) {
        if(cookieIsMember == 1) {
            return is === 'is' ? true : false;
        }
        return is === 'is' ? false : true;
    } else {
        if(window['RvstData']) {
            var status = RvstData.isMember;
            if(status == 1) {
                swSetCookie(cname,status,10,hname);
                return is === 'is' ? true : false;
            }
        } else {
            var registerPageArray = registerPage.split(',');
            for(var i=0;i<registerPageArray.length;i++) {
                if(!registerPageArray[i].trim())
                    continue;
                if(currentUrl.includes(registerPageArray[i].toLowerCase()) || pageUrlVisited('includes',registerPageArray[i].toLowerCase())) {
                    swSetCookie(cname,'1',10,hname);
                    return is === 'is' ? true : false;
                }
            }
        }
    }
    return is === 'is' ? false : true;
}

__smartWidgetConditionFunctions__.addedToCart = function addedToCart(is, pagesObj) {
    var currentUrl = window.location.href.toLowerCase();
    var cartPage = pagesObj.cartPage;
    var pageUrlVisited = __smartWidgetConditionFunctions__.pageUrlVisited;
    if(window['memberCart']) {
        var status = memberCart.pCount > 0 ? 1 : 0;
        if(status == 1) {
            return is === 'is' ? true : false;
        }
    }
    else if(window['rvtsCart']) {
        var status = rvtsCart.count > 0 ? 1 : 0;
        if(status == 1) {
            return is === 'is' ? true : false;
        }
    } else {
        var cartPageArray = cartPage.split(',');
        for(var i=0;i<cartPageArray.length;i++) {
            if(!cartPageArray[i].trim())
                continue;
            if(currentUrl.includes(cartPageArray[i].toLowerCase()) || pageUrlVisited('includes',cartPageArray[i].toLowerCase())) {
                return is === 'is' ? true : false;
            }
        }
    }
    return is === 'is' ? false : true;
}

__smartWidgetConditionFunctions__.userOrdered = function userOrdered(is, pagesObj) {
    var currentUrl = window.location.href.toLowerCase();
    var orderPage = pagesObj.orderPage;
    var cname = 'rvts_user_ordered';
    var cookieUserOrdered = swGetCookie(cname);
    var pageUrlVisited = __smartWidgetConditionFunctions__.pageUrlVisited;
    if(cookieUserOrdered) {
        if(cookieUserOrdered == 1) {
            return is === 'is' ? true : false;
        }
        return is === 'is' ? false : true;
    } else {
        if(window['RvstData']) {
            var status = RvstData.Ordered;
            if(status == 1) {
                swSetCookie(cname,status,10,hname);
                return is === 'is' ? true : false;
            }
        } else {
            var orderPageArray = orderPage.split(',');
            for(var i=0;i<orderPageArray.length;i++) {
                if(!orderPageArray[i].trim())
                    continue;
                if(currentUrl.includes(orderPageArray[i].toLowerCase()) || pageUrlVisited('includes',orderPageArray[i].toLowerCase())) {
                    swSetCookie(cname,'1',10,hname);
                    return is === 'is' ? true : false;
                }
            }
        }
    }
    return is === 'is' ? false : true;
}

__smartWidgetConditionFunctions__.WebpushCheck = function WebpushCheck(status) {
    var webpushStatus = swGetCookie('revotas_web_push');
    if(webpushStatus === status)
        return true;
    return false;
}

__smartWidgetConditionFunctions__.checkRecentlyViewed = function checkRecentlyViewed() {
    var cName = 'rvts_product_history_array';
    var cookieRecentlyViewed = decodeURIComponent(swGetCookie(cName));
    if(cookieRecentlyViewed) {
        localStorage.setItem(cName,encodeURIComponent(cookieRecentlyViewed));
        swSetCookie(cName,'',-1,hname);
    } else {
        cookieRecentlyViewed = localStorage.getItem(cName) ? decodeURIComponent(localStorage.getItem(cName)) : null;
    }
    if(cookieRecentlyViewed) {
        var productArray = JSON.parse(cookieRecentlyViewed);
		productArray = productArray.filter(function(product) {
            if(!product[0].date)return false;
            else {
                var productDate = new Date(product[0].date);
                var now = new Date();
                var timeDiff = Math.round((now.getTime() - productDate.getTime()) / (1000*60*60));
                return timeDiff < 48;
            }
        });
		localStorage.setItem(cName,encodeURIComponent(JSON.stringify(productArray)));
        if(productArray.length > 0)
            return true;
        else 
            return false;
    } else 
        return false;
}

__smartWidgetConditionFunctions__.executeScript = function executeScript(script) {
    return window.eval('(function(){'+script+'})();')
}

__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.deviceType, name: 'Device type', params: [{
    type: 'list',
    elements: [{
        name: 'Desktop',
        value: 'desktop'
    },{
        name: 'Mobile',
        value: 'mobile'
    }]
}]});

__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.pageUrl, name: 'Page URL', params: [{
    type: 'list',
    elements: [{
        name: 'IS',
        value: 'is'
    },{
        name: 'IS NOT',
        value: 'isnot'
    },{
        name: 'LIKE',
        value: 'includes'
    },{
        name: 'NOT LIKE',
        value: 'notincludes'
    }]
}, {
    type: 'text'
}]});

__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.pageUrlVisited, name: 'Page URL Visited', params: [{
    type: 'list',
    elements: [{
        name: 'IS',
        value: 'is'
    },{
        name: 'IS NOT',
        value: 'isnot'
    },{
        name: 'LIKE',
        value: 'includes'
    },{
        name: 'NOT LIKE',
        value: 'notincludes'
    }]
}, {
    type: 'text'
}]});

__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.firstVisit, name: 'First visit'});
__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.isMember, name: 'Is member', params:[
    {
        type: 'list',
        elements: [{
            name:'IS',
            value:'is'
        },{
            name:'IS NOT',
            value:'isnot'
        }]
    }]});
__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.addedToCart, name: 'Added to cart', params:[
    {
        type: 'list',
        elements: [{
            name:'IS',
            value:'is'
        },{
            name:'IS NOT',
            value:'isnot'
        }]
    }]});
__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.userOrdered, name: 'User made order', params:[
    {
        type: 'list',
        elements: [{
            name:'IS',
            value:'is'
        },{
            name:'IS NOT',
            value:'isnot'
        }]
    }]});
__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.timeSpent, name: 'Time spent on site', params:[
    {
        type: 'list',
        elements: [{
            name:'Seconds',
            value:'seconds'
        },{
            name:'Minutes',
            value:'minutes'
        }]
    },{
        type: 'text'
    }]});
__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.lastPopupShow, name: 'Last shown(days)', params:[{type: 'text'}]});



__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.WebpushCheck, name: 'Webpush', params:[
    {
        type: 'list',
        elements: [{
            name:'Allowed',
            value:'true'
        },{
            name:'Blocked',
            value:'false'
        }]
    }]});


__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.checkRecentlyViewed, name: 'Recently Viewed'});

__smartWidgetFunctions__.push({f: __smartWidgetConditionFunctions__.executeScript, name: 'JS Code', params:[{type: 'multiline'}]});

var swNavigateListenerSet = false;

function swMessageListener(message) {
    var cust_id = rvtsPopupArray[0].rvts_customer_id;
	var origin = message.origin;
	var data = message.data;
	if(data.swCheckConnection && data.cust_id == cust_id) {
        var targetWindow = null;
        if(data.type === 'iframe')targetWindow=window.parent;
        else if(data.type === 'window')targetWindow=window.opener;
		targetWindow.postMessage({swCheckConnection: true, href: window.location.href},origin);
        if(!swNavigateListenerSet) {
            window.addEventListener('beforeunload', function() {
                targetWindow.postMessage('swConnectionLost',origin);
                window.removeEventListener('message',swMessageListener);
            })
            swNavigateListenerSet = true;
        }
	} else if(data.swPreview) {
        executeGroup(data.conditionConfig, {
          registerPage: data.registerPage, 
          cartPage: data.cartPage, 
          orderPage: data.orderPage}).then(function(result) {
              if(result) {
                if(data.html)data.html = decodeURIComponent(data.html);
                if(data.scriptCode)data.scriptCode = decodeURIComponent(data.scriptCode);
                var previewCustId = data.custId;
                var previewPopupId = data.popupId;
                var previewFormId = data.formId;
                var previewRcpLink = data.rcp_link;
                rvtsPopup(data, false, previewCustId, previewPopupId, previewFormId, previewRcpLink, true);
              }
          });
    } else if(data.swExecJSCode) {
        window.eval(decodeURIComponent(data.JSCode));
    }
}

if(typeof rvtsPopupArray !== 'undefined' && rvtsPopupArray[0].rvts_customer_id) {
    window.addEventListener('message',swMessageListener);
}

if(!rvtsPopupAlreadyShown && window['rvtsPopupArray'] && rvtsPopupArray.length > 0) {
    (async function() {
        var popupArray = [];
        var cust_id = rvtsPopupArray[0].rvts_customer_id;
        popupArray = await swSessionConfig;
        if(popupArray)popupArray=JSON.parse(popupArray);
        if(!popupArray) {
            popupArray = await fetch('https://f.revotas.com/frm/smartwidgets/get_smartwidget_config.jsp?cust_id=' + cust_id)
            .then(function(resp) {return resp.json();});
            sessionStorage.setItem('sw_session_config',JSON.stringify(popupArray));
        }
        var breakFor = false;
        for(popup of popupArray) {
            let obj = popup.object;
            let nonBlocking = obj.nonBlocking;
            let formId = popup.formId;
            let popupId = popup.popupId;
            let rcpLink = popup.rcp_link
            let registerPage = popup.registerPage;
            let cartPage = popup.cartPage;
            let orderPage = popup.orderPage;
            if(obj.enabled && nonBlocking==1) {
                executeGroup(obj.conditionConfig, {
                  registerPage: registerPage, 
                  cartPage: cartPage, 
                  orderPage: orderPage}, popupId).then(function(result) {
                      if(result) {
                        if(obj.html)obj.html = decodeURIComponent(obj.html);
                        if(obj.scriptCode)obj.scriptCode = decodeURIComponent(obj.scriptCode);
                        rvtsPopup(obj,false,cust_id,popupId,formId,rcpLink,false);
                      }
                  });
            } else if(obj.enabled && !breakFor) {
                await executeGroup(obj.conditionConfig, {
                  registerPage: registerPage, 
                  cartPage: cartPage, 
                  orderPage: orderPage}, popupId).then(function(result) {
                      if(result) {
                        if(obj.html)obj.html = decodeURIComponent(obj.html);
                        if(obj.scriptCode)obj.scriptCode = decodeURIComponent(obj.scriptCode);
                        rvtsPopup(obj,false,cust_id,popupId,formId,rcpLink,false);
                        if(!['sticky','drawer','script','productAlert','socialProof'].includes(obj.type))breakFor = true;
                      }
                  });    
            }
        }
    })();
}