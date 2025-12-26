/*****************************
******************************
*****************************/

var __smartWidgetFunctions__ = [];
var __smartWidgetConditionFunctions__ = {};

var hname = window.location.hostname;

if(hname.substr(0,3) == 'www') {
    hname = hname.substring(3,hname.length);
}

function generateSessionId() {
    return [...Array(30)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
}

if(!sessionStorage.getItem('rvts_session_id')) {
    sessionStorage.setItem('rvts_session_id', generateSessionId());
}

var rvtsSessionId = sessionStorage.getItem('rvts_session_id');
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
            fetchParams+='&url='+window.location.href;
            fetchParams+='&user_agent='+navigator.userAgent;
            fetchParams+='&activity_type='+activityType;
            fetchParams+='&session_id='+rvtsSessionId;
            if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
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

function stickyPopup(params) {

    var scriptRun = false;
    var scriptTags = [];

    var init;

    var close = function() {
        if(!status.open)
            throw new Error('Popup is already hidden');
        popup.style.transition = 'top ' + closeDuration +' ease 0s';
        emptyDiv.style.height = '0';
        popup.style.top = '-' + height;
        fixedElements.forEach(function(element) {
            element.style.transition = 'top ' + closeDuration +' ease 0s';
            element.style.top = '0';
        });
        setTimeout(function(){
            emptyDiv.remove();
            popup.remove();
            scriptTags.forEach(function(tag){tag.remove();});
            status.open = false;
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

    //var button = closeButton();
    //button.addEventListener('click', close);
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
        iframe.setAttribute('width',width === 'auto' ? '100%' : width);
        iframe.setAttribute('height',height === 'auto' ? '100%' : height);
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


    return {
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
                    if(!isPreview) {
                        saveLastPopupShow(popupId);
                        var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id='+formId+'&url='+window.location.href+'&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
                        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                        fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                        if(params.autoCloseDelay) {
                            setTimeout(function() {
                                thisPopup.close();
                            }, parseDuration(params.autoCloseDelay));
                        }
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
                                    fetchParams+='&url='+window.location.href;
                                    fetchParams+='&user_agent='+navigator.userAgent;
                                    fetchParams+='&activity_type='+activityType;
                                    fetchParams+='&session_id='+rvtsSessionId;
                                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
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
}

function slidingPopup(params) {

    var scriptRun = false;
    var scriptTags = [];

    var init;

    var close = function() {
        if(!status.open)
            throw new Error('Popup is already hidden');
        popup.style.transition = ps[0] + ' ' + closeDuration + ' ease 0s';
        var s = styleToHide.split('|');
        popup.style[s[0]] = s[1];
        setTimeout(function(){
            if(overlayColor) {
                popup.remove();
                overlay.remove();
                document.body.style.overflow = '';
            } else {
                popup.remove();
            }
            scriptTags.forEach(function(tag){tag.remove();});
            status.open = false;
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
    var button = closeButton();
    button.addEventListener('click', close);

    popup.style.backgroundColor = backgroundColor;
    popup.style.width = width;
    popup.style.height = height;
    popup.style.position = 'fixed';
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
        iframe.setAttribute('width',width === 'auto' ? '100%' : width);
        iframe.setAttribute('height',height === 'auto' ? '100%' : height);
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

    return {
        show: function(isPreview, custId, popupId, formId) {
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
                        overlay.addEventListener('click', function() {
                            thisPopup.close();
                        });
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
                    if(!isPreview) {
                        saveLastPopupShow(popupId);
                        var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id='+formId+'&url='+window.location.href+'&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
                        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                        fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                        if(params.autoCloseDelay) {
                            setTimeout(function() {
                                thisPopup.close();
                            }, parseDuration(params.autoCloseDelay));
                        }
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
                                    fetchParams+='&url='+window.location.href;
                                    fetchParams+='&user_agent='+navigator.userAgent;
                                    fetchParams+='&activity_type='+activityType;
                                    fetchParams+='&session_id='+rvtsSessionId;
                                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
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
    }
}

function fadingPopup(params) {

    var scriptRun = false;
    var scriptTags = [];

    var init;

    var close = function() {
        if(!status.open)
            throw new Error('Popup is already hidden');
        popup.style.transition = 'opacity ' + closeDuration + ' ease 0s';
        popup.style.opacity = '0';
        if(overlayColor) {
            overlay.style.transition = 'opacity ' + closeDuration + ' ease 0s';
            overlay.style.opacity = '0';
        }
        setTimeout(function(){
            if(overlayColor) {
                popup.remove();
                overlay.remove();
                document.body.style.overflow = '';
            } else {
                popup.remove();
            }
            scriptTags.forEach(function(tag){tag.remove();});
            status.open = false;
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

    var button = closeButton();

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
    if(html) {
        popup.innerHTML = html;
    } else if(iframeLink) {
        var iframe = document.createElement('iframe');
        params.iframeClassName.split(' ').forEach(function(element) {
            if(element)iframe.classList.add(element);
        });
        iframe.setAttribute('src',iframeLink);
        iframe.setAttribute('width',width === 'auto' ? '100%' : width);
        iframe.setAttribute('height',height === 'auto' ? '100%' : height);
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



    return {
        show: function(isPreview, custId, popupId, formId) {
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
                        overlay.addEventListener('click', function() {
                            thisPopup.close();
                        });
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
                    if(!isPreview) {
                        saveLastPopupShow(popupId);
                        var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id='+formId+'&url='+window.location.href+'&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
                        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                        fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                        if(params.autoCloseDelay) {
                            setTimeout(function() {
                                thisPopup.close();
                            }, parseDuration(params.autoCloseDelay));
                        }
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
                                    fetchParams+='&url='+window.location.href;
                                    fetchParams+='&user_agent='+navigator.userAgent;
                                    fetchParams+='&activity_type='+activityType;
                                    fetchParams+='&session_id='+rvtsSessionId;
                                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
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
    }
}

function drawerPopup(params) {
    
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

    var close = function() {
        if(!status.open)
            throw new Error('Popup is already hidden');
        popup.style.transition = ps[0] + ' ' + closeDuration + ' ease 0s';
        var s = styleToHide.split('|');
        popup.style[s[0]] = s[1];
        setTimeout(function(){
            if(overlayColor) {
                popup.remove();
                overlay.remove();
                document.body.style.overflow = '';
            } else {
                popup.remove();
            }
            scriptTags.forEach(function(tag){tag.remove();});
            status.open = false;
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
    
    if(html) {
        popup.innerHTML = html;
    } else if(iframeLink) {
        iframe = document.createElement('iframe');
        params.iframeClassName.split(' ').forEach(function(element) {
            if(element)iframe.classList.add(element);
        });
        iframe.setAttribute('src',iframeLink);
        iframe.setAttribute('width',width === 'auto' ? '100%' : width);
        iframe.setAttribute('height',height === 'auto' ? '100%' : height);
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
                        overlay.addEventListener('click', function() {
                            thisPopup.close();
                        });
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
                    if(!isPreview) {
                        saveLastPopupShow(popupId);
                        var fetchParams = 'cust_id='+custId+'&popup_id='+popupId+'&form_id='+formId+'&url='+window.location.href+'&user_agent='+navigator.userAgent+'&activity_type=0'+'&session_id='+rvtsSessionId;
                        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                        fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                        if(params.autoCloseDelay) {
                            setTimeout(function() {
                                thisPopup.close();
                            }, parseDuration(params.autoCloseDelay));
                        }
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
                                    fetchParams+='&url='+window.location.href;
                                    fetchParams+='&user_agent='+navigator.userAgent;
                                    fetchParams+='&activity_type='+activityType;
                                    fetchParams+='&session_id='+rvtsSessionId;
                                    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
                                    fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams);
                                    if(activityType=='1')saveSwSource(popupId);
                                });
                            }
                        });
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

    return {
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
}

function rvtsPopup(params, isPreview, custId, popupId, formId, isLivePreview) {
    var popup;
    if(params.type === 'sticky') {
        popup = stickyPopup(params);
    } else if(params.type === 'sliding') {
        popup = slidingPopup(params);
    } else if(params.type === 'fading') {
        popup = fadingPopup(params);
    } else if(params.type === 'drawer') {
        popup = drawerPopup(params);
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
                if(params.scriptCode)window.eval('(function(){'+params.scriptCode+'}).call(popup);');
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
                if(params.scriptCode)window.eval('(function(){'+params.scriptCode+'}).call(popup);');
            }
            setTimeout(function() {
                document.addEventListener('mouseleave', leaveEvent);
            }, 2000);
        } else if(params.trigger === 'afterLoad') {
            var run = function() {
                setTimeout(function() {
                    if(popup){
                        if(!isLivePreview)popup.show(false, custId, popupId, formId);
                        else popup.show(true);
                    }
                    if(params.scriptCode)window.eval('(function(){'+params.scriptCode+'}).call(popup);');
                },parseDuration(params.delay));
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
                rvtsPopup(data, false, previewCustId, previewPopupId, previewFormId, true);
              }
          });
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
            var obj = popup.object;
            var formId = popup.formId;
            var popupId = popup.popupId;
            var registerPage = popup.registerPage;
            var cartPage = popup.cartPage;
            var orderPage = popup.orderPage;
            if(obj.enabled) {
                await executeGroup(obj.conditionConfig, {
                  registerPage: registerPage, 
                  cartPage: cartPage, 
                  orderPage: orderPage}, popupId).then(function(result) {
                      if(result) {
                        if(obj.html)obj.html = decodeURIComponent(obj.html);
                        if(obj.scriptCode)obj.scriptCode = decodeURIComponent(obj.scriptCode);
                        rvtsPopup(obj,false,cust_id,popupId,formId,false);
                        if(obj.type!='sticky' && obj.type!='drawer' && obj.type!='script')breakFor = true;
                      }
                  });
                if(breakFor)
                    break;
            }
        }
    })();
}