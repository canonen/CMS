var rvtsRecoCode = 30;

//UTM Tracker code
if(typeof rvtsRecoPreviewMode === 'undefined' && (typeof window.rvtsUTMTrackerAdded === 'undefined' || window.rvtsUTMTrackerAdded === rvtsRecoCode)) {
    (function() {
        var _rTag = document.getElementsByTagName('script')[0];
        var _rcTag = document.createElement('script');
        _rcTag.type = 'text/javascript';
        _rcTag.async = 'true';
        _rcTag.src = ('https://l.revotas.com/trc/api/rvts_tracker.js');
        _rTag.parentNode.insertBefore(_rcTag, _rTag);
    })();
    window.rvtsUTMTrackerAdded = rvtsRecoCode;
}

//Order Tracker code
if(typeof rvtsRecoPreviewMode === 'undefined' && (typeof window.rvtsOrderTrackerAdded === 'undefined' || window.rvtsOrderTrackerAdded === rvtsRecoCode)) {
    (function() {
        var _rTag = document.getElementsByTagName('script')[0];
        var _rcTag = document.createElement('script');
        _rcTag.type = 'text/javascript';
        _rcTag.async = 'true';
        _rcTag.src = ('https://l.revotas.com/trc/api/rvts_order_tracker.js');
        _rTag.parentNode.insertBefore(_rcTag, _rTag);
    })();
    window.rvtsOrderTrackerAdded = rvtsRecoCode;
}

//Activity Tracker code
if(typeof rvtsRecoPreviewMode === 'undefined' && (typeof window.rvtsActivityTrackerAdded === 'undefined' || window.rvtsActivityTrackerAdded === rvtsRecoCode)) {
    (function() {
        var _rTag = document.getElementsByTagName('script')[0];
        var _rcTag = document.createElement('script');
        _rcTag.type = 'text/javascript';
        _rcTag.async = 'true';
        _rcTag.src = ('https://l.revotas.com/trc/api/rvts_activity_tracker.js');
        _rTag.parentNode.insertBefore(_rcTag, _rTag);
    })();
    window.rvtsActivityTrackerAdded = rvtsRecoCode;
}

var hname = window.location.hostname;

var recommendationIntervalList = [];
var resizeFuncList = [];

if(hname.substr(0,3) == 'www') {
    hname = hname.substring(3,hname.length);
} else {
    hname = '.' + hname;
}

var queryList = {
    '50': 'rvts_top_seller',
    '60': 'rvts_price_drop',
    '70': 'rvts_new_product',
    '80': 'rvts_back_in_stock',
    '90': 'rvts_buy_also',
    '100': 'rvts_similar',
    '110': 'rvts_you_might',
    '120': 'rvts_view_also',
    '130': 'rvts_recently',
    '140': 'rvts_trending'
}

var typeList = {
    '50': 'topseller',
    '60': 'pricedrop',
    '70': 'newproduct',
    '80': 'backinstock',
    '90': 'buyalso',
    '100': 'similar',
    '110': 'youmight',
    '120': 'viewalso',
    '130': 'recently',
    '140': 'trending'
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

var custId = rvtsRecommendationObj.rvts_customer_id;

function rcGetCookie(cname) {
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

function rcSetCookie(name,value,days,ckie_dmn) {
    var expires = "";
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days*24*60*60*1000));
        expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + (value || "")  + expires +";domain="+ckie_dmn+ "; path=/";
}

(function() {
    var shouldUpdate = false;
    var cName = 'rvts_product_history_array';
    var recentProducts = rcGetCookie(cName);
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
        rcSetCookie(cName,encodeURIComponent(JSON.stringify(products)),10,hname);
    }
    else if(decodedProducts === recentProducts) {
        rcSetCookie(cName,encodeURIComponent(recentProducts),10,hname);
    }
})();

function saveRecoSource(campId) {
    rcSetCookie('revotas_source','other',7,hname);
    rcSetCookie('revotas_medium','reco',7,hname);
    rcSetCookie('revotas_campaign',campId,7,hname);
}

function saveProductToCookie(product) {
    product.date = new Date();
    var cName = 'rvts_product_history_array';
    var cookieProductList = decodeURIComponent(rcGetCookie(cName));
    if(cookieProductList) {
        localStorage.setItem(cName,encodeURIComponent(cookieProductList));
        rcSetCookie(cName,'',-1,hname);
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

function getProductsFromCookie() {
    var cName = 'rvts_product_history_array';
    var products = decodeURIComponent(rcGetCookie(cName));
	if(products) {
		localStorage.setItem(cName,encodeURIComponent(products));
		rcSetCookie(cName,'',-1,hname);
	} else {
		products = localStorage.getItem(cName) ? decodeURIComponent(localStorage.getItem(cName)) : null;
	}
    if(products) {
        products = JSON.parse(products);
        products = products.filter(function(product) {
            if(!product[0].date)return false;
            else {
                var productDate = new Date(product[0].date);
                var now = new Date();
                var timeDiff = Math.round((now.getTime() - productDate.getTime()) / (1000*60*60));
                return timeDiff < 48;
            }
        });
        localStorage.setItem(cName,encodeURIComponent(JSON.stringify(products)));
        return products;
    } else 
        return [];
}

if(window['PRODUCT_DATA'] && PRODUCT_DATA.length == 1) {
    var currentProduct = PRODUCT_DATA[0];
    var product = {};
    product.p_id = currentProduct.id;
    product.category_id = currentProduct.category_ids;
    product.category = currentProduct.category;
    product.name = currentProduct.name;
    product.image_link = currentProduct.image;
    product.product_price = currentProduct.total_base_price.toFixed(2) + ' ' + currentProduct.currency;
    product.product_sales_price = currentProduct.total_sale_price.toFixed(2) + ' ' + currentProduct.currency;
    product.link = window.location.href;
    window['rvtsRecoCurrentProduct'] = product;
    saveProductToCookie(product);
} else if(window['productDetailModel']) {
    var currentProduct = productDetailModel;
    var product = {};
    product.p_id = currentProduct.productId;
    product.category_id = currentProduct.productCategoryId;
    product.name = currentProduct.productName;
    product.image_link = (currentProduct.productImages[0].imagePath.indexOf('https:')!==0 ? window.location.origin : '') + currentProduct.productImages[0].imagePath;
    product.product_price = currentProduct.productPriceKDVIncluded.toFixed(2) + ' ' + currentProduct.productCurrency;
    product.link = window.location.href;
    window['rvtsRecoCurrentProduct'] = product;
    saveProductToCookie(product);
}

function saveActivity(activityType,type,campaignId) {
    if(typeof rvtsRecoPreviewMode !== 'undefined')
        return;
    var rvtsUserId = rcGetCookie('revotas_web_push_user');
    var rvtsToken = rcGetCookie('rvts_token');
    var rvtsEmail = rcGetCookie('rvts_email');
    var fetchParams = 'cust_id='+custId+'&recommendation_type='+type+'&url='+window.location.href+'&user_agent='+navigator.userAgent+'&activity_type='+activityType+'&session_id='+rvtsSessionId+'&campaign_id='+campaignId;
    if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
    if(rvtsToken)fetchParams += '&token=' + rvtsToken;
    if(rvtsEmail)fetchParams += '&email=' + rvtsEmail;
    fetch('https://f.revotas.com/frm/recommendation/save_recommendation_activity.jsp?' + fetchParams);
    if(activityType=='1')saveRecoSource(campaignId);
}

function renderVerticalPreview(contentList, width, height, selector, title, type, previewObj, mainDiv, campaignId) {
	var elementHeight = 80;
	var marginHeight = 10;
	var borderHeight = 1;
	var divHeight = height;
    var titleDivs = title.split(' ').map(function(t) {
        return '<div>' + t + '</div>';
    });

	var elementCount = contentList.length;
    
    var containerSize = Math.floor(divHeight / (elementHeight + borderHeight * 2 + marginHeight)) - 1;
	containerSize > elementCount ? containerSize = elementCount : false;
    previewObj.setSize(containerSize,'vertical');
    if(!previewObj.getRefresh() && previewObj.getElement()) {
        previewObj.getElement().style.height = divHeight + 'px';
        if(previewObj.getElement().children[0].children[1])previewObj.getElement().children[0].children[1].style.height = (divHeight-(titleDivs.length*16)) + 'px';
        return previewObj.getElement();
    }

	var verticalDiv = document.createElement('div');
	verticalDiv.style.height = divHeight + 'px';
    verticalDiv.style.width = '100%';
	verticalDiv.style.position = 'relative';
	verticalDiv.style.overflow = 'hidden';
	verticalDiv.innerHTML = '<div style="position: absolute; width: 100%;"></div>';

	verticalDiv.children[0].innerHTML = '<div style="background-color:black;color:white;width: 100%; line-height: 16px; font-size: 13px; text-align:center; top: 0;" class="'+selector+'_preview_title">'+titleDivs.join('')+'</div><div style="align-items:center;display: flex; flex-direction: column; height: '+(divHeight-(titleDivs.length*16))+'px; justify-content: space-evenly;"> </div>';
    contentList.forEach(function(element,index) {
        if(index<containerSize) {
            var imageDiv = document.createElement('div');
            imageDiv.style.border = '1px solid black';
            imageDiv.style.height = elementHeight + 'px';
            imageDiv.style.width = 'auto';
            imageDiv.style.cursor = 'pointer';
            imageDiv.classList.add(selector+'_preview_image');
            var imageElement = document.createElement('img');
            imageDiv.appendChild(imageElement);
            imageElement.src = element.image_link;
            imageElement.style.height = '100%';
            imageElement.style.width = 'auto';
            if(index<containerSize-1)imageDiv.style.marginBottom=marginHeight + 'px';
            verticalDiv.children[0].children[1].appendChild(imageDiv);
            imageDiv.addEventListener('click', function() {
                var pLink = element.link;
                window.open(pLink + '?utm_source=revotas&utm_medium=reco&utm_campaign=' + typeList[type], '_self');
                saveActivity(1,type,campaignId);
            });
        }
    });
    if(previewObj.getElement())previewObj.getElement().remove();
    previewObj.setElement(verticalDiv,'vertical');
    mainDiv.parentElement.insertBefore(verticalDiv, mainDiv);
	return verticalDiv;
}

function renderHorizontalPreview(contentList, width, height, selector, title, type, previewObj, mainDiv, campaignId) {
	var elementWidth = 80;
	var marginWidth = 10;
	var borderWidth = 1;
	var divWidth = width;

	var elementCount = contentList.length;
    
    var containerSize = Math.floor(divWidth / (elementWidth + borderWidth * 2 + marginWidth));
	containerSize > elementCount ? containerSize = elementCount : false;
    previewObj.setSize(containerSize,'horizontal');
    if(!previewObj.getRefresh() && previewObj.getElement()) {
        previewObj.getElement().style.width = divWidth + 'px';
        previewObj.getElement().style.height = height + 'px';
        if(previewObj.getElement().children[0].children[1])previewObj.getElement().children[0].children[1].style.width = divWidth + 'px';
        return previewObj.getElement();
    }
    
	var horizontalDiv = document.createElement('div');
	horizontalDiv.style.width = divWidth + 'px';
    horizontalDiv.style.height = height+'px';
	horizontalDiv.style.position = 'relative';
	horizontalDiv.style.overflow = 'hidden';
	horizontalDiv.innerHTML = '<div style="position: absolute; height: 100%;"><div class="'+selector+'_preview_title" style="background-color:black;color:white;position: absolute; top: 0;width:100%;display:flex;justify-content:center;">'+title+'</div> <div style="height: 100%; align-items: center; display: flex; flex-direction: row; width: '+divWidth+'px; justify-content: space-evenly;"> </div> </div>';

	horizontalDiv.children[0].children[1].innerHTML = '';
    contentList.forEach(function(element,index) {
        if(index<containerSize) {
            var imageDiv = document.createElement('div');
            imageDiv.style.border = '1px solid black';
            imageDiv.style.height = elementWidth + 'px';
            imageDiv.style.width = 'auto';
            imageDiv.style.cursor = 'pointer';
            imageDiv.classList.add(selector+'_preview_image');
            var imageElement = document.createElement('img');
            imageDiv.appendChild(imageElement);
            imageElement.src = element.image_link;
            imageElement.style.height = '100%';
            imageElement.style.width = 'auto';
            if(index<containerSize-1)imageDiv.style.marginRight=marginWidth + 'px';
            horizontalDiv.children[0].children[1].appendChild(imageDiv);
            imageDiv.addEventListener('click', function() {
                var pLink = element.link;
                window.open(pLink + '?utm_source=revotas&utm_medium=reco&utm_campaign=' + typeList[type], '_self');
                saveActivity(1,type,campaignId);
            });
        }
    });
    if(previewObj.getElement())previewObj.getElement().remove();
    previewObj.setElement(horizontalDiv,'horizontal');
    mainDiv.parentElement.insertBefore(horizontalDiv, mainDiv);
	return horizontalDiv;
}

function fillContainer(mainDiv,contentList,title,type,contSize,selector,campaignId,currencyConfig) {
    if(currencyConfig && currencyConfig!=='null')currencyConfig=currencyConfig.filter(config=>config.active==1)[0];
    if(currencyConfig==='null')currencyConfig=null;
    var insideDiv = false;
    
    var previewObj = (function() {
        var element = null;
        var size = 0;
        var refresh = true;
        var elementType = 'none';
            return {
                setSize: function(s,t) {
                    if(size!==s || elementType!==t)
                        refresh=true;
                    else
                        refresh=false;
                    size=s;
                    elementType=t;
                },
                setElement: function(e,t) {
                    if(elementType !== t)
                        refresh=true;
                    else
                        refresh=false;
                    element=e;
                    elementType=t;
                },
                getElement: function() {return element;},
                getRefresh: function() {return refresh;}
            };
    })();
    
    
    function numberToFixed(number,toFixed) {
        number=number.toString();
        var indexOfDot = number.indexOf('.');
        if(indexOfDot !== -1) {
            if(toFixed==0) {
                number = number.substring(0,indexOfDot);
            } else {
                number = number.split('').filter((e,i)=>{
                    return (indexOfDot+toFixed)>=i;
                }).join('');
                var decimalCount = number.length - indexOfDot - 1;
                if(toFixed>decimalCount)number=number.concat(Array.apply(null, Array(toFixed-decimalCount)).map(Number.prototype.valueOf,0).join(''));
            }
        } else if(toFixed>0) {
            number=number.concat(['.']);
            number=number.concat(Array.apply(null, Array(toFixed)).map(Number.prototype.valueOf,0).join(''));
        }
        return number;
    }
    
    function formatCurrency(number,currencyConfig) {
        var originalNumber = number;
        try {
            number = number.toString();
            number = number.replace(/[^0-9.,]/g, '');
            number = number.split(',').join('.');
            number = parseFloat(number);
            var indexOfComma = currencyConfig.format.indexOf(',');
            var indexOfDot = currencyConfig.format.indexOf('.');
            var thousandSeparator = indexOfComma < indexOfDot ? ',' : '.';
            var decimalSeparator = indexOfComma < indexOfDot ? '.' : ',';
            if(indexOfComma === -1 || indexOfDot === -1)thousandSeparator = '';
            var decimalCount = currencyConfig.format.length - currencyConfig.format.indexOf(decimalSeparator) - 1;
            number = numberToFixed(number,decimalCount);
            var parts = number.split('.').length === 2 ? number.split('.') : number.split(',');
            var normalPart = parts[0];
            var decimalPart = parts[1] ? parts[1] : '';

            normalPart = normalPart.split('').reverse().map((e,i,arr)=>{
                if((i+1)%3===0 && arr.length>(i+1))return thousandSeparator+e;
                else return e;
            }).reverse().join('');
            var currency = normalPart + (decimalPart ? (decimalSeparator + decimalPart) : '');
            if(currencyConfig.language === 'EN') currency = currencyConfig.currency + currency;
            else if(currencyConfig.language === 'TR') currency = currency + ' ' + currencyConfig.currency;
            return currency;
        } catch(e) {
            return originalNumber;
        }
        
    }
    
    
    var containerSize;
    var elementWidth;
    var marginWidth;
    var borderWidth;
    var leftButtonWidth;
    var rightButtonWidth;
    
    if(!mainDiv)
        throw new Error('Invalid query selector: ' + selector);
    if(!contentList || contentList.length == 0)
        throw new Error('Empty list');
    
    document.addEventListener('mousemove',function(e) {
        var rect = mainDiv.getBoundingClientRect();
        var left = rect.left, top = rect.top, width = rect.width, height = rect.height;
        var x = e.clientX - left;
        var y = e.clientY - top;
        if(x>=0 && x<=width && y>=0 && y<=height)
            insideDiv = true;
        else
            insideDiv = false;
    });
    
    var animationStyle = document.createElement('style');
    animationStyle.innerHTML = '.lds-grid { display: inline-block; position: relative; width: 80px; height: 80px; } .lds-grid div { position: absolute; width: 16px; height: 16px; border-radius: 50%; background: #ff6600; animation: lds-grid 1.2s linear infinite; } .lds-grid div:nth-child(1) { top: 8px; left: 8px; animation-delay: 0s; } .lds-grid div:nth-child(2) { top: 8px; left: 32px; animation-delay: -0.4s; } .lds-grid div:nth-child(3) { top: 8px; left: 56px; animation-delay: -0.8s; } .lds-grid div:nth-child(4) { top: 32px; left: 8px; animation-delay: -0.4s; } .lds-grid div:nth-child(5) { top: 32px; left: 32px; animation-delay: -0.8s; } .lds-grid div:nth-child(6) { top: 32px; left: 56px; animation-delay: -1.2s; } .lds-grid div:nth-child(7) { top: 56px; left: 8px; animation-delay: -0.8s; } .lds-grid div:nth-child(8) { top: 56px; left: 32px; animation-delay: -1.2s; } .lds-grid div:nth-child(9) { top: 56px; left: 56px; animation-delay: -1.6s; } @keyframes lds-grid { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }';
    document.head.appendChild(animationStyle);
    mainDiv.style.display = 'flex';
    mainDiv.style.alignItems = 'center';
    mainDiv.style.justifyContent = 'center';
    mainDiv.innerHTML = '<div class="lds-grid"><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div>'
    
    var cssPromise = new Promise(function(resolve,reject) {
        function calculateCss() {
            
            var leftButton = document.createElement('div');
            leftButton.classList.add(selector + '_buttons__left');
            var rightButton = document.createElement('div');
            rightButton.classList.add(selector + '_buttons__right');
            leftButton.style.position = 'fixed';
            rightButton.style.position = 'fixed';
            leftButton.style.visibility = 'hidden';
            rightButton.style.visibility= 'hidden';
            leftButton.innerHTML = '<img>';
            rightButton.innerHTML = '<img>';
            document.body.appendChild(leftButton);
            document.body.appendChild(rightButton);
            var emptyDiv = document.createElement('div');
            emptyDiv.classList.add(selector + '-container__element');
            emptyDiv.style.display = 'none';
            document.body.appendChild(emptyDiv);
            elementWidth = getComputedStyle(emptyDiv).width;
            elementWidth = parseInt(elementWidth.substr(0, elementWidth.length - 2));
            marginWidth = getComputedStyle(emptyDiv).marginLeft;
            marginWidth = parseInt(marginWidth.substr(0, marginWidth.length - 2));
            borderWidth = getComputedStyle(emptyDiv).borderWidth;
            borderWidth = parseInt(borderWidth.substr(0, borderWidth.length - 2));
            leftButtonWidth = leftButton.getBoundingClientRect().width;
            rightButtonWidth = rightButton.getBoundingClientRect().width;
            document.body.removeChild(emptyDiv);
            document.body.removeChild(leftButton);
            document.body.removeChild(rightButton);
            if(marginWidth == 0 || leftButtonWidth == 0 || rightButtonWidth == 0) {
                setTimeout(calculateCss, 500);
            }
            else
                resolve();
        };
        calculateCss();
    });
    
    cssPromise.then(function() {
        
        mainDiv.style = '';
        mainDiv.innerHTML = '';
        animationStyle.remove();
    
        var shiftWidth = elementWidth + marginWidth + borderWidth * 2;

        var elementList = [];
        var headerDiv = document.createElement('div');
        headerDiv.classList.add(selector + '-header');
        headerDiv.innerHTML = title;
        var containerDiv = document.createElement('div');
        containerDiv.classList.add(selector + '-container');
        containerDiv.style.left = '0px';
        var flexDiv = document.createElement('div');
        flexDiv.classList.add(selector + '-container__flex');
        contentList.forEach(function(element, index) {
            var elementDiv = document.createElement('div');
            elementDiv.addEventListener('click', function() {
                window.open(element.link + '?utm_source=revotas&utm_medium=reco&utm_campaign=' + typeList[type], '_self');
                saveActivity(1,type,campaignId);
            });
            elementDiv.classList.add(selector + '-container__element');
            if(index==0)elementDiv.classList.add('current');
            flexDiv.appendChild(elementDiv);
            elementList.push(elementDiv);

            //Fill element
            var imageDiv = document.createElement('div');
            imageDiv.classList.add(selector + '-container__element_image');
            elementDiv.appendChild(imageDiv);

            var image = document.createElement('img');
            image.src = element.image_link;
            imageDiv.appendChild(image);

            var name = document.createElement('div');
            name.classList.add(selector + '-container__element_name');
            if(!element.product_sales_price) name.classList.add('original-price');
            //try {
            //    name.innerText = decodeURIComponent(escape(element.name));
            //} catch(e) {
                name.innerHTML = element.name;
            //}
            elementDiv.appendChild(name);
            
            var price = document.createElement('div');
            price.classList.add(selector + '-container__element_price');
            if(!element.product_sales_price) price.classList.add("original-price");
            price.innerText = currencyConfig !== null ? formatCurrency(element.product_price, currencyConfig) : element.product_price;
            elementDiv.appendChild(price);
            
            if(element.product_sales_price) {
                var salesPrice = document.createElement('div');
                salesPrice.classList.add(selector + '-container__element_sales_price');
                salesPrice.innerText = currencyConfig !== null ? formatCurrency(element.product_sales_price, currencyConfig) : element.product_sales_price;
                elementDiv.appendChild(salesPrice);
                
                var salesDiscount = document.createElement('div');
                salesDiscount.classList.add(selector + '-container__element_sales_discount');
                
                var priceNumber = parseInt(element.product_price.replace(/\D/g,''));
                var salesPriceNumber = parseInt(element.product_sales_price.replace(/\D/g,''));
                
                var discountPercent = Math.ceil(((priceNumber-salesPriceNumber)/priceNumber)*100);
                
                salesDiscount.innerText = discountPercent + '%';
                
                
                
                elementDiv.appendChild(salesDiscount);
            }
        });
        containerDiv.appendChild(flexDiv);

        var buttonsDivL = document.createElement('div');
        var buttonsDivR = document.createElement('div');
        buttonsDivL.classList.add(selector + '_buttons__left');
        buttonsDivR.classList.add(selector + '_buttons__right');
        var leftButton = document.createElement('img');
        var rightButton = document.createElement('img');
        buttonsDivL.appendChild(leftButton);
        buttonsDivR.appendChild(rightButton);

        var elementCount = contentList.length

        flexDiv.style.width = (elementWidth*elementCount + marginWidth*(elementCount+1) + elementCount*2*borderWidth) + 'px';
        mainDiv.style.display = 'block';
        mainDiv.appendChild(headerDiv);
        mainDiv.appendChild(containerDiv);
        mainDiv.appendChild(buttonsDivL);
        mainDiv.appendChild(buttonsDivR);

        function shiftCurrent(direction) {
            var counter = 0;
            var currentIndex;
            elementList.forEach(function(element) {
                if(element.classList.contains('current')) {
                    currentIndex = counter;
                }
                counter++;
            });
            if(direction == 'right') {
                if(currentIndex == (elementCount - containerSize)) {
                    elementList[currentIndex].classList.remove('current');
                    elementList[0].classList.add('current');
                } else {
                    elementList[currentIndex].classList.remove('current');
                    elementList[currentIndex+1].classList.add('current');
                }
            } else if(direction == 'left') {
                if(currentIndex == 0) {
                    elementList[currentIndex].classList.remove('current');
                    elementList[elementCount-containerSize].classList.add('current');
                } else {
                    elementList[currentIndex].classList.remove('current');
                    elementList[currentIndex-1].classList.add('current');
                }
            }

            return currentIndex;
        }
        
        function shiftLeft(isInterval) {
            if(isInterval === true && insideDiv)
                return;
            if(mainDiv.style.display === 'none')
                return;
            var element = document.querySelector('.' + selector + '-container');
            if(!element)return;
            var leftPos = element.style.left;
            leftPos = parseInt(leftPos.substr(0,leftPos.length-2));
            leftPos += shiftWidth;
            element.style.left = leftPos + 'px';
            var currentIndex = shiftCurrent('left');
            if(currentIndex==0) element.style.left = ((containerSize - elementCount) * shiftWidth) + 'px';
        }                                                                           
        
        function shiftRight(isInterval) {
            if(isInterval === true && insideDiv)
                return;
            if(mainDiv.style.display === 'none')
                return;
            var element = document.querySelector('.' + selector + '-container');
            if(!element)return;
            var leftPos = element.style.left;
            leftPos = parseInt(leftPos.substr(0,leftPos.length-2));
            leftPos -= shiftWidth;
            element.style.left = leftPos + 'px';
            var currentIndex = shiftCurrent('right');
            if(currentIndex==elementCount - containerSize) element.style.left = '0px';
        }
        
        document.querySelector('.' + selector + '_buttons__left').addEventListener('click', shiftLeft);

        document.querySelector('.' + selector + '_buttons__right').addEventListener('click', shiftRight);  
        
        recommendationIntervalList = recommendationIntervalList.filter(function(intervalObj) {
            if(intervalObj[selector]) {
                clearInterval(intervalObj[selector]);
                return false;
            } else
                return true;
        });
        recommendationIntervalList.push({[selector]:setInterval(function() {shiftRight(true);}, 3000)});
        
        var parentDivObj = (function() {
            var width = 0;
            var height = 0;
            return {
                setWidth: function(w) {
                    width = w;
                },
                setHeight: function(h) {
                    height = h;
                },
                getWidth: function() {
                    return width;
                },
                getHeight: function() {
                    return height;
                }
            }
        })();
        
        function resizeFunc(e,p) {
            var previewDiv = null;
            var newWidth;
			var newHeight;
            
            if(typeof e === 'number' && typeof p === 'number') {
                newWidth = e;
                newHeight = p;
            } else {
                if(e) {
                    newHeight = e.target.innerHeight;
                    newWidth = e.target.innerWidth;
                } else {
                    newHeight = window.innerHeight;
                    newWidth = window.innerWidth;
                }
                parentDivObj.setHeight(newHeight);
                parentDivObj.setWidth(newWidth);
            }
            
            
            if(newWidth<newHeight)
                previewDiv = renderVerticalPreview(contentList, newWidth, newHeight, selector, title, type, previewObj, mainDiv, campaignId);
            else
                previewDiv = renderHorizontalPreview(contentList, newWidth, newHeight, selector, title, type, previewObj, mainDiv, campaignId);
            previewDiv.style.display = 'none';
            /*var previewTitle = document.querySelector('.' + selector + '_preview_title');
            if(previewTitle) {
                function setTitlePosition() {
                    setTimeout(function() {
                        if(previewTitle.getBoundingClientRect().height > 0)
                            previewTitle.style.top = (newHeight - previewTitle.getBoundingClientRect().height) / 2 + previewTitle.getBoundingClientRect().height + 'px';
                        else
                            setTitlePosition();
                    }, 250);
                }
                setTitlePosition();
            }*/
            var metric = newWidth < newHeight ? newWidth : newHeight;
            if(metric<=200) {
                mainDiv.style.display = 'none';
                previewDiv.style.display = 'block';
            } else {
                mainDiv.style.display = 'block';
                previewDiv.style.display = 'none';
            }
            
            containerSize = Math.ceil((newWidth - (leftButtonWidth + rightButtonWidth))/Math.round((elementWidth*elementCount + marginWidth*(elementCount-1) + elementCount*2*borderWidth)/elementCount)) - 1;
            
            if(contSize && contSize>0 && contSize<containerSize) containerSize = parseInt(contSize);
            
            if(containerSize>contentList.length)containerSize=contentList.length;
            mainDiv.style.width = (elementWidth*containerSize + marginWidth*(containerSize+1) + containerSize*2*borderWidth) + 'px';
            var counter = 0;
            var currentIndex;
            elementList.forEach(function(element) {
                if(element.classList.contains('current')) {
                    currentIndex = counter;
                }
                counter++;
            });
            if(elementCount - currentIndex < containerSize) {
                for(var i=elementCount - currentIndex;i<containerSize;i++)
                    shiftLeft();
            }
        }
        
        
        window.addEventListener('resize', resizeFunc);
        
        resizeFuncList = resizeFuncList.filter(function(obj) {
            if(obj[selector]) {
                window.removeEventListener('resize',obj[selector]);
                return false;
            } else
                return true;
        });
        resizeFuncList.push({[selector]:resizeFunc});
        
        
        resizeFunc();
        
        setInterval(function() {
            var newWidth = mainDiv.parentElement.getBoundingClientRect().width;
            var newHeight = mainDiv.parentElement.getBoundingClientRect().height;
            if(newWidth>0 && newHeight>0 && (parentDivObj.getWidth() != newWidth || parentDivObj.getHeight() != newHeight)) {
                parentDivObj.setWidth(newWidth);
                parentDivObj.setHeight(newHeight);
                resizeFunc(newWidth,newHeight);
            }
        }, 250);
        
        saveActivity(0,type,campaignId);
     });
}

/*function getConfigs(custId) {
    fetch('https://f.revotas.com/frm/recommendation/get_recommendation_config.jsp?cust_id=' + custId)
    .then(function(resp) {return resp.json();})
    .then(function(config_param) {
        config_param.forEach(function(config) {
            fetchProducts(custId,config);
        });
    });
}*/

function renderRecommendation(mainDiv,css,contSize,limit,campaignId,selector,campType,campTitle,rcpLink,currencyConfig) {
    css=css.split('<rvts_recommendation_selector>').join(selector + '_' + campaignId);
    mainDiv.classList.remove(selector);
    mainDiv.classList.add(selector + '_' + campaignId);
    
    mainDiv.innerHTML = '';
    
    var newStyle = document.createElement('style');
    newStyle.innerHTML = css;
    document.head.appendChild(newStyle);
    if(campType == 130) {
        var resp = getProductsFromCookie();
        resp = resp.map(function(element) {return element[0];});
        if(limit && limit>0)resp = resp.filter(function(element, index) {return index<limit;});
        if(resp.length>0)fillContainer(mainDiv, resp, campTitle, campType, contSize, selector + '_' + campaignId,campaignId,currencyConfig);
    } else {
        var productId = null;
        if([90,100,120].includes(parseInt(campType))) {
            if(window['PRODUCT_DATA'] && PRODUCT_DATA.length == 1) {
                var currentProduct = PRODUCT_DATA[0];
                productId = currentProduct.id;
            } else if(window['productDetailModel']) {
                var currentProduct = productDetailModel;
                productId = currentProduct.id;
            }
        }
        fetch('https://'+rcpLink+'/rrcp/imc/recommendation/get_recommendation.jsp?cust_id='+custId+'&type='+campType+(productId?('&product_id='+productId):''))
        .then(function(resp) {return resp.json();})
        .then(function(resp) {
            resp = resp.filter(function(element) {return element!=null;})
            resp = resp.map(function(element) {return element[0];});
            if(limit && limit>0)resp = resp.filter(function(element, index) {return index<limit;});
            if(resp.length>0)fillContainer(mainDiv, resp, campTitle, campType, contSize, selector + '_' + campaignId,campaignId,currencyConfig);
        });
    }
    
}

/*var queryList = {
    '50': 'rvts_top_seller',
    '60': 'rvts_price_drop',
    '70': 'rvts_new_product',
    '80': 'rvts_back_in_stock',
    '90': 'rvts_buy_also',
    '100': 'rvts_similar',
    '110': 'rvts_you_might',
    '120': 'rvts_view_also',
    '130': 'rvts_recently',
    '140': 'rvts_trending'
}*/

async function getConfigs(custId) {
    function shuffleArr(a) {
        for (let i = a.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [a[i], a[j]] = [a[j], a[i]];
        }
        return a;
    }
    
    if(typeof PAGE_TYPE !== 'undefined') {
        var configList = getAllConfigs();
        var queryArray = [];
        var recentlyViewCount = getProductsFromCookie().length;
        var userId = rcGetCookie('revotas_web_push_user');
        var knownUser = userId && (recentlyViewCount>=5);
        
        if(PAGE_TYPE === 'home') {
            if(knownUser) {
                await populateRecoContainer(configList,null,null,null,70);
                await populateRecoContainer(configList,userId,null,null,110,130);
            } else {
                await populateRecoContainer(configList,null,null,null,70);
                await populateRecoContainer(configList,null,null,null,140);
            }
        } else if(PAGE_TYPE === 'category') {
            var categoryId = CATEGORY_DATA.name;
            if(knownUser) {
                await populateRecoContainer(configList,userId,null,null,110);
                await populateRecoContainer(configList,null,null,categoryId,50);
            } else {
                await populateRecoContainer(configList,null,null,categoryId,50);
            }
        } else if(PAGE_TYPE === 'product') {
            if(knownUser && (typeof rvtsSWCurrentProduct !== 'undefined')) {
                var productId = rvtsSWCurrentProduct.p_id;
                var b1 = await populateRecoContainer(configList,null,productId,null,90);
                var b2 = await populateRecoContainer(configList,null,productId,null,100);
                var b3 = await populateRecoContainer(configList,userId,null,null,110);
                var b4 = await populateRecoContainer(configList,null,productId,null,120);
                if(!(b1 || b2 || b3 || b4)) {
                    var categoryId = null;
                    if(typeof PRODUCT_DATA !== 'undefined' && PRODUCT_DATA.length === 1) {
                        categoryId = PRODUCT_DATA[0].category;
                    }
                    await populateRecoContainer(configList,null,null,null,50);
                }
            } else {
                var categoryId = null;
                if(typeof PRODUCT_DATA !== 'undefined' && PRODUCT_DATA.length === 1) {
                    categoryId = PRODUCT_DATA[0].category;
                }
                await populateRecoContainer(configList,null,null,categoryId,50);
                if(typeof rvtsSWCurrentProduct !== 'undefined') {
                    var productId = rvtsSWCurrentProduct.p_id;
                    await populateRecoContainer(configList,null,productId,null,100);
                }
            }
        } else if(PAGE_TYPE === 'cart' || PAGE_TYPE === 'order') {
            //if(knownUser) {
                var productList = [];
                if(typeof rvtsCart !== 'undefined' && rvtsCart.product && rvtsCart.product.length > 0) {
                    productList = rvtsCart.product;
                }
                var productIdList = [];
                var categoryIdList = [];
                var productCategoryMap = {};
                var campaignProductBuyAlsoList = []; 
                var campaignProductSimilarList = []; 
                var campaignProductViewAlsoList = []; 
                productList.forEach(function(product) {
                    var p_id = product.pId;
                    var category_name = product.category_name;
                    productCategoryMap[p_id] = {category_name: category_name};
                });
                
            
                var productCountBuyAlso = 0;
                var productCountSimilar = 0;
                var productCountViewAlso = 0;
                
                for(var key in productCategoryMap) {
                    var productsBuyAlso = await populateRecoContainer(configList,null,key,null,90,null,true);
                    var productsSimilar = await populateRecoContainer(configList,null,key,null,100,null,true);
                    var productsViewAlso = await populateRecoContainer(configList,null,key,null,120,null,true);
                    
                    productsBuyAlso = productsBuyAlso.filter(product => {
                        var alreadyExists = false;
                        productList.forEach(p => {
                            if(p.pId == product.p_id)alreadyExists=true;
                        });
                        return !alreadyExists;
                    });
                    
                    productsSimilar = productsSimilar.filter(product => {
                        var alreadyExists = false;
                        productList.forEach(p => {
                            if(p.pId == product.p_id)alreadyExists=true;
                        });
                        return !alreadyExists;
                    });
                    
                    productsViewAlso = productsViewAlso.filter(product => {
                        var alreadyExists = false;
                        productList.forEach(p => {
                            if(p.pId == product.p_id)alreadyExists=true;
                        });
                        return !alreadyExists;
                    });
                    
                    productCategoryMap[key].buy_also = productsBuyAlso;
                    productCategoryMap[key].similar = productsSimilar;
                    productCategoryMap[key].view_also = productsViewAlso;
                    
                    productCountBuyAlso += productsBuyAlso.length > 0 ? 1 : 0;
                    productCountSimilar += productsSimilar.length > 0 ? 1 : 0;
                    productCountViewAlso += productsViewAlso.length > 0 ? 1 : 0;
                }
            
                var productPerBuyAlso = productCountBuyAlso == 0 ? 0 : Math.ceil(10/productCountBuyAlso);
                var productPerSimilarAlso = productCountSimilar == 0 ? 0 : Math.ceil(10/productCountSimilar);
                var productPerViewAlso = productCountViewAlso == 0 ? 0 : Math.ceil(10/productCountViewAlso);
                
            
                for(var key in productCategoryMap) {
                    var productsBuyAlso = productCategoryMap[key].buy_also;
                    var productsSimilar = productCategoryMap[key].similar;
                    var productsViewAlso = productCategoryMap[key].view_also;
                    
                    var counter1 = 0;
                    productsBuyAlso.forEach(product => {
                        var pId = product.p_id;
                        var filtered = campaignProductBuyAlsoList.filter(e => e.p_id==pId);
                        if(filtered.length===0 && counter1<productPerBuyAlso){
                            campaignProductBuyAlsoList.push(product);
                            counter1++;
                        }
                    });
                    var counter2 = 0;
                    productsSimilar.forEach(product => {
                        var pId = product.p_id;
                        var filtered = campaignProductSimilarList.filter(e => e.p_id==pId);
                        if(filtered.length===0 && counter2<productPerSimilarAlso){
                            campaignProductSimilarList.push(product);
                            counter2++;
                        }
                    });
                    var counter3 = 0;
                    productsViewAlso.forEach(product => {
                        var pId = product.p_id;
                        var filtered = campaignProductViewAlsoList.filter(e => e.p_id==pId);
                        if(filtered.length===0 && counter3<productPerViewAlso){
                            campaignProductViewAlsoList.push(product);
                            counter3++;
                        }
                    });
                }
                if(campaignProductBuyAlsoList.length>0){
                    campaignProductBuyAlsoList = campaignProductBuyAlsoList.slice(0,10);
                    await populateRecoContainer(configList,null,key,null,90,null,null,campaignProductBuyAlsoList);
                }
                if(campaignProductSimilarList.length>0){
                    campaignProductSimilarList = campaignProductSimilarList.slice(0,10);
                    await populateRecoContainer(configList,null,key,null,100,null,null,campaignProductSimilarList);
                }
                if(campaignProductViewAlsoList.length>0){
                    campaignProductViewAlsoList = campaignProductViewAlsoList.slice(0,10);
                    await populateRecoContainer(configList,null,key,null,120,null,null,campaignProductViewAlsoList);
                }
            //}
        } else if(PAGE_TYPE === '404' || PAGE_TYPE === 'search') {
            if(knownUser) {
                await populateRecoContainer(configList,userId,null,null,110,130);
            } else {
                await populateRecoContainer(configList,null,null,null,50);
            }
        } 
        
    } 
    Object.values(queryList).forEach(function(selector) {
        var recommendationDivList = Array.from(document.querySelectorAll('.'+selector));
        recommendationDivList.forEach(function(divElement) {
            var force = divElement.getAttribute('force');
            var campaignId = divElement.getAttribute('campaign_id');
            if(campaignId && (typeof PAGE_TYPE === 'undefined' || force === 'true')) {
                fetch('https://f.revotas.com/frm/recommendation/get_recommendation_config_new.jsp?cust_id=' + custId + '&camp_id=' + campaignId)
                .then(function(resp) {return resp.json();})
                .then(function(resp) {
                    if(typeof resp === 'object') {
                        if(resp.status == 1) {
                            var css = decodeURIComponent(resp.template_css);
                            var contSize = resp.container_size;
                            var limit = resp.products_num_block;
                            var campType = resp.camp_type;
                            var rcpLink = resp.rcp_link;
                            var campTitle = resp.camp_title;
                            var currencyConfig = resp.currency_config;
                            renderRecommendation(divElement,css,contSize,limit,campaignId,selector,campType,campTitle,rcpLink,currencyConfig);
                        }
                    }
                });
            }
        });
    });

}

function getAllConfigs() {
    return fetch('https://f.revotas.com/frm/recommendation/get_all_recommendation_config.jsp?cust_id=' + custId)
    .then(function(resp) {return resp.json();});
}

async function getCampaignProducts(campType,userId,productId,categoryId,rcpLink) {
    var productList = [];
    if(campType == 130) {
        productList = getProductsFromCookie();
        productList = productList.map(function(element) {return element[0];});
        return productList;
    } else {
        var productList = await fetch('https://'+rcpLink+'/rrcp/imc/recommendation/get_recommendation.jsp?cust_id='+custId+'&type='+campType+(userId?('&user_id='+userId):'')+(productId?('&product_id='+productId):''),{
            method:'POST',
            headers: {
                    'Content-Type':'application/json'
                },
            body: (categoryId ? categoryId : '')
        }).then(function(resp) {return resp.json();})
            .then(function(resp) {
                if([90,100,120].includes(parseInt(campType))) {
                    resp = resp[0];
                    resp = resp.slice(0,10);
                    return resp;
                } else {
                    resp = resp.filter(function(element) {return element!=null;});
                    resp = resp.map(function(element) {return element[0];});
                    resp = resp.slice(0,10);
                    return resp;
                } 
            }).catch(()=>[]);
    }
    return productList;
}

async function populateRecoContainer(configList,userId,productId,categoryId,mainScenario,fallbackScenario,returnProducts,productList) {
    var selector = queryList[mainScenario];
    var fallbackSelector = queryList[fallbackScenario];
    var configs = await configList.then(resp=>resp.filter(e=>e.camp_type==mainScenario)[0]);
    if(configs) {
        var css = decodeURIComponent(configs.template_css);
        var contSize = configs.container_size;
        var limit = configs.products_num_block;
        var campType = configs.camp_type;
        var rcpLink = configs.rcp_link;
        var campaignId = configs.camp_id;
        var campTitle = configs.camp_title;
        var currencyConfig = configs.currency_config;
        var campaignProducts = productList;
        if(!campaignProducts) campaignProducts = await getCampaignProducts(campType,userId,productId,categoryId,rcpLink);
        if(returnProducts) return campaignProducts;
        var populated = false;
        if(campaignProducts && campaignProducts.length>=3) {
            document.querySelectorAll('.' + selector).forEach(mainDiv => {
                var force = mainDiv.getAttribute('force');
                if(force !== 'true') {
                    css=css.split('<rvts_recommendation_selector>').join(selector + '_' + campaignId);
                    mainDiv.classList.remove(selector);
                    mainDiv.classList.add(selector + '_' + campaignId);
                    mainDiv.innerHTML = '';
                    var newStyle = document.createElement('style');
                    newStyle.innerHTML = css;
                    document.head.appendChild(newStyle);
                    fillContainer(mainDiv, campaignProducts, campTitle, campType, contSize, selector + '_' + campaignId,campaignId,currencyConfig);
                    populated = true;
                }
            });
        }
    }  
    if(fallbackScenario && campaignProducts.length<3) {
        var fallbackConfigs = await configList.then(resp=>resp.filter(e=>e.camp_type==fallbackScenario)[0]);
        if(fallbackConfigs) {
            var css = decodeURIComponent(fallbackConfigs.template_css);
            var contSize = fallbackConfigs.container_size;
            var limit = fallbackConfigs.products_num_block;
            var campType = fallbackConfigs.camp_type;
            var rcpLink = fallbackConfigs.rcp_link;
            var campaignId = fallbackConfigs.camp_id;
            var campTitle = fallbackConfigs.camp_title;
            var currencyConfig = fallbackConfigs.currency_config;
            var fallbackProducts = await getCampaignProducts(fallbackScenario,userId,productId,categoryId,rcpLink);
            if(fallbackProducts && fallbackProducts.length>=3) {
                document.querySelectorAll('.' + fallbackSelector).forEach(mainDiv => {
                    var force = mainDiv.getAttribute('force');
                    if(force !== 'true') {
                        css=css.split('<rvts_recommendation_selector>').join(fallbackSelector + '_' + campaignId);
                        mainDiv.classList.remove(fallbackSelector);
                        mainDiv.classList.add(fallbackSelector + '_' + campaignId);
                        mainDiv.innerHTML = '';
                        var newStyle = document.createElement('style');
                        newStyle.innerHTML = css;
                        document.head.appendChild(newStyle);
                        fillContainer(mainDiv, fallbackProducts, campTitle, campType, contSize, fallbackSelector + '_' + campaignId,campaignId,currencyConfig);
                        populated = true;
                    }
                });
            }
        }
    }
    return populated;
}

if(typeof rvtsRecoPreviewMode === 'undefined')
	getConfigs(custId);