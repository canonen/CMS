var rvtsPersSearchCode = 40;

//UTM Tracker code
if(typeof window.rvtsUTMTrackerAdded === 'undefined' || window.rvtsUTMTrackerAdded === rvtsPersSearchCode) {
    (function() {
        var _rTag = document.getElementsByTagName('script')[0];
        var _rcTag = document.createElement('script');
        _rcTag.type = 'text/javascript';
        _rcTag.async = 'true';
        _rcTag.src = ('https://l.revotas.com/trc/api/rvts_tracker.js');
        _rTag.parentNode.insertBefore(_rcTag, _rTag);
    })();
    window.rvtsUTMTrackerAdded = rvtsPersSearchCode;
}

//Order Tracker code
if(typeof window.rvtsOrderTrackerAdded === 'undefined' || window.rvtsOrderTrackerAdded === rvtsPersSearchCode) {
    (function() {
        var _rTag = document.getElementsByTagName('script')[0];
        var _rcTag = document.createElement('script');
        _rcTag.type = 'text/javascript';
        _rcTag.async = 'true';
        _rcTag.src = ('https://l.revotas.com/trc/api/rvts_order_tracker.js');
        _rTag.parentNode.insertBefore(_rcTag, _rTag);
    })();
    window.rvtsOrderTrackerAdded = rvtsPersSearchCode;
}

//Activity Tracker code
if(typeof window.rvtsActivityTrackerAdded === 'undefined' || window.rvtsActivityTrackerAdded === rvtsPersSearchCode) {
    (function() {
        var _rTag = document.getElementsByTagName('script')[0];
        var _rcTag = document.createElement('script');
        _rcTag.type = 'text/javascript';
        _rcTag.async = 'true';
        _rcTag.src = ('https://l.revotas.com/trc/api/rvts_activity_tracker.js');
        _rTag.parentNode.insertBefore(_rcTag, _rTag);
    })();
    window.rvtsActivityTrackerAdded = rvtsPersSearchCode;
}

var psSessionConfigResolver = null;
var psSessionConfig = new Promise((resolve,reject)=>{
    psSessionConfigResolver = resolve;
    if(sessionStorage.getItem('ps_session_config'))
        resolve(sessionStorage.getItem('ps_session_config'));
});

var psSessionConfigSet = false;
window.addEventListener('storage', function(e) {
    if(e.key === 'get_ps_session_config' && e.newValue) {
        var psConfig = sessionStorage.getItem('ps_session_config');
        if(psConfig) {
            localStorage.setItem('ps_local_config', psConfig);
            localStorage.removeItem('ps_local_config');
        }
    }
    if(e.key === 'ps_local_config' && e.newValue && !psSessionConfigSet) {
        sessionStorage.setItem('ps_session_config',e.newValue);
        psSessionConfigSet = true;
        psSessionConfigResolver(e.newValue);
    }
});

localStorage.setItem('get_ps_session_config','get');
localStorage.removeItem('get_ps_session_config');
setTimeout(()=>{
    psSessionConfigResolver(null);
},250);

function initializeRvtsPersSearch() {
    if(window['rvtsPersSearchArray'] && rvtsPersSearchArray.length > 0) {
            var cust_id = rvtsPersSearchArray[0].rvts_customer_id;
            psSessionConfig.then(resp => {
                if(resp) {
                    resp = JSON.parse(resp);
                    var configurationObj = resp.object;
                    var status = resp.status;
                    var rcp_link = resp.rcp_link;
                    if(status===1) {
                        var configurations = decodeConfigs(configurationObj);
                        Array.from(document.querySelectorAll(configurations.inputSelector)).forEach(input => {
                            rvtsPersonalizedSearch(configurations, cust_id, input, rcp_link);
                        });
                    }
                } else {
                    fetch('https://f.revotas.com/frm/perssearch/get_perssearch_config.jsp?cust_id='+cust_id)
                    .then(resp => resp.json())
                    .then(resp => {
                        sessionStorage.setItem('ps_session_config',JSON.stringify(resp));
                        var configurationObj = resp.object;
                        var status = resp.status;
                        var rcp_link = resp.rcp_link;
                        if(status===1) {
                            var configurations = decodeConfigs(configurationObj);
                            Array.from(document.querySelectorAll(configurations.inputSelector)).forEach(input => {
                                rvtsPersonalizedSearch(configurations, cust_id, input, rcp_link);
                            });
                        }
                    });
                }
            });
    }
}

if(document.readyState === 'complete') {
    setTimeout(function() {
        initializeRvtsPersSearch();
    }, 500);
} else {
    window.addEventListener('load', () => {
        setTimeout(function() {
            initializeRvtsPersSearch();
        }, 500);
    });
}

function decodeConfigs(configs) {
    for(var key in configs) {
        if(key==='categories')
            configs[key] = configs[key].map(element => {
                return {
                    name: decodeURIComponent(element.name),
                    link: decodeURIComponent(element.link),
                    pinned: decodeURIComponent(element.pinned)
                };
            });
        else if(key==='synonyms')
            configs[key] = configs[key].map(element => {
                return {
                    original: decodeURIComponent(element.original),
                    synonym: decodeURIComponent(element.synonym)
                };
            });
        else if(key==='redirects')
            configs[key] = configs[key].map(element => {
                return {
                    query: decodeURIComponent(element.query),
                    link: decodeURIComponent(element.link)
                };
            });
        else if(key==='recommendedQueries')
            configs[key] = configs[key].map(element => decodeURIComponent(element));
        else if(key!=='filterConfigs' && key!=='currencyConfigs')
            configs[key] = decodeURIComponent(configs[key]);
    }
    return configs;
}

function rvtsPersonalizedSearch(searchConfig, custId, input, rcp_link) {
    var sortParam = searchConfig.sortCriteria ? searchConfig.sortCriteria : 'date';
    input.value = '';
    var submitButton = null;
    if(searchConfig.submitSelector) {
        submitButton = eval(searchConfig.submitSelector);
    }
    
    var backupProductList = null;
    
    var search_request_object = {
        sortParam : sortParam,
        searchParam: ''
    };
    
    var ACTIVITY_SEARCH = 3;
    var ACTIVITY_CLICK = 4;
    
    var resultCount = 0;
    
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
    
    var currencyConfig=null;
    if(searchConfig.currencyConfigs)currencyConfig=searchConfig.currencyConfigs.filter(config=>config.active==1)[0];
    
    function mouseEnterWithDelay(element,callback, delay) {
        var timeOutRef = null;
        element.addEventListener('mouseenter', function() {
            timeOutRef = setTimeout(() => callback.call(this), delay);
        });
        element.addEventListener('mouseleave', function() {
            clearTimeout(timeOutRef);
        });
    }
    
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
                },250);
            }
        }
    }
    
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
			normalPart = normalPart.split('').reverse();
            normalPart = normalPart.map((e,i)=>{
                if((i+1)%3===0 && normalPart.length>(i+1))return thousandSeparator+e;
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
    
    function replaceWord(param,word,value) {
        if(!param)return param;
        word = word.toLowerCase();
        value = value.toLowerCase();
        var str = param.toLowerCase();
        if(str.length===0)return param;
        var upperLimit = str.length-word.length;
        var replaceList = [];
        for(var i=0;i<=upperLimit;i++) {
            var tempWord = str.substr(i,word.length);
            if(tempWord === word) {
                var lowerBound = i>0?i-1:0;
                var length = word.length + (i>0?2:1);
                var extraction = str.substr(lowerBound,length);
                if(extraction.trim() === word) {
                    replaceList.push([extraction,extraction.replace(word,value)]);
                }
            }
        }
        replaceList.forEach(e=>str=str.replace(e[0],e[1]));
        return str;
    }
    
    var newStyle = document.createElement('style');
    newStyle.innerHTML = searchConfig.css;

    document.head.appendChild(newStyle);
    
    var hname = window.location.hostname;

    if(hname.substr(0,3) == 'www') {
        hname = hname.substring(3,hname.length);
    }
    
    var maxZIndex = 2147483646/2;
    
    var filterBox = (function() {
        
        var filterListArray = [];
        var callbackFn = null;
    
        var createFilter = function (option) {
            function generateId() {
                return [...Array(10)].map(i=>(~~(Math.random()*36)).toString(36)).join('');
            }
            var enabled = null;
            var name = option.name;
            var title = option.title;
            var type = option.type;
            var element = document.createElement('div');
            element.classList.add('rvts_personalized_search_main-filter');
            var lowerRange = null;
            var upperRange = null;
            var selectList = null;
            var selectListObject = {};
            var head = document.createElement('div');
            var headId = generateId();
            head.innerHTML = '<span>'+decodeURIComponent(title)+'</span><div class="rvts_personalized_search_main-filter-search-icon"><img src="https://l.revotas.com/trc/perssearch/searchicon.png"></div>';
            var searchButton = head.querySelector('div');
            searchButton.addEventListener('click', () => {
                enabled = true;
                if(typeof callbackFn === 'function')callbackFn.call(element, filterListArray);
            });
            var filterTitle = head.querySelector('span');
            filterTitle.addEventListener('click', () => {
                if(body.classList.contains('rvts_personalized_search_main-filter-expand-' + type))
                    body.classList.remove('rvts_personalized_search_main-filter-expand-' + type);
                else
                    body.classList.add('rvts_personalized_search_main-filter-expand-' + type);
            });
            element.appendChild(head);
            var body = document.createElement('div');
            body.style.height = 0;
            body.classList.add('rvts_personalized_search_main-filter-' + type);
            if(type === 'select') {
                enabled = true;
                searchButton.style.display = 'none';
                var inputDiv = document.createElement('div');
                inputDiv.innerHTML = '<input type="text">';
                inputDiv.querySelector('input').addEventListener('keyup', e => {
                    var val = e.target.value.toLocaleLowerCase();
                    selectList.forEach(select => select.style.display = '');
                    var filteredList = selectList.filter(filterItem => !filterItem.querySelector('label').innerText.toLocaleLowerCase().includes(val));
                    filteredList.forEach(select => select.style.display = 'none');
                });
                var innerBody = document.createElement('div');
                body.appendChild(inputDiv);
                body.appendChild(innerBody);
                selectList = option.list.map(el => {
                    var label = decodeURIComponent(el.string);
                    var meta = decodeURIComponent(el.meta);
                    if(!meta) meta = name;
                    var newId = generateId();
                    var newDiv = document.createElement('div');
                    newDiv.classList.add('rvts_personalized_search_main-filter-item');
                    newDiv.innerHTML = '<input meta="'+meta+'" id="'+newId+'" type="checkbox"><label for="'+newId+'">'+label+'</label>';
                    newDiv.querySelector('input').addEventListener('change', () => {
                        if(typeof callbackFn === 'function')callbackFn.call(element, filterListArray);
                    });
                    innerBody.appendChild(newDiv);
                    selectListObject[encodeURIComponent(label) + '_' + encodeURIComponent(meta)] = newDiv.querySelector('input');
                    return newDiv;
                });
                element.appendChild(body);
                if(selectList.length<10)inputDiv.style.display = 'none';
            } else if(type === 'range') {
                enabled = false;
                lowerRange = document.createElement('input');
                lowerRange.type = 'number';
                var dash = document.createElement('span');
                dash.innerText = '-';
                upperRange = document.createElement('input');
                upperRange.type = 'number';
                body.appendChild(lowerRange);
                body.appendChild(dash);
                body.appendChild(upperRange);
                if(option.range) {
                    lowerRange.value = option.range[0];
                    upperRange.value = option.range[1];
                }
                element.appendChild(body);
            }

            var getValues = function() {
                if(selectList) {
                    return enabled && {
                        name:name,
                        type:type,
                        list:selectList
                        .filter(selectDiv => selectDiv.querySelector('input').checked)
                        .map(selectDiv => {
                            return {
                                string:selectDiv.querySelector('label').innerText,
                                meta:selectDiv.querySelector('input').getAttribute('meta')
                            };
                        })
                    };
                } else if (lowerRange && upperRange) {
                    return enabled && {
                        name:name,
                        type:type,
                        range:[lowerRange.value,upperRange.value]
                    };
                }
            }

            var returnValue = {
                getValues: getValues,
                getFilters: function() {
                    if(selectList) {
                        return selectList
                            .filter(selectDiv => selectDiv.querySelector('input').checked)
                            .map(selectDiv => {
                                var filterDiv = document.createElement('div');
                                filterDiv.classList.add('rvts_personalized_search_main-filter-element');
                                filterDiv.innerHTML = '<span>'+selectDiv.querySelector('label').innerText+'</span><span>x</span>';
                                filterDiv.children[1].addEventListener('click', () => {
                                    selectDiv.querySelector('input').checked = false;
                                    filterDiv.remove();
                                    if(typeof callbackFn === 'function')callbackFn.call(element, filterListArray);
                                });
                                filterDiv.filterValues = getValues();
                                return filterDiv;
                            });
                    } else if (lowerRange && upperRange) {
                        var filterDiv = document.createElement('div');
                        filterDiv.classList.add('rvts_personalized_search_main-filter-element');
                        filterDiv.innerHTML = '<span>'+lowerRange.value+' - '+upperRange.value+'</span><span>x</span>';
                        filterDiv.children[1].addEventListener('click', () => {
                            filterDiv.remove();
                            enabled = false;
                            if(typeof callbackFn === 'function')callbackFn.call(element, filterListArray);
                        });
                        filterDiv.filterValues = getValues();
                        return enabled ? [filterDiv] : [];
                    }
                },
                element: element
            };
            filterListArray.push(returnValue);
            return returnValue;
        };
        return {
            createFilter: createFilter,
            getFilterList: () => {return filterListArray;},
            subscribe: function(fn) {
                callbackFn = fn;
            }
        };
    })();
    
    function convertProductFormat(product) {
        var obj = {
            p_id: product.productID,
            name: product.productName,
            image_link: product.imageLink,
            link: product.link,
            product_price: product.productPrice
        }
        if(product.productSalesPrice)
            obj.product_sales_price = product.productSalesPrice;
        return obj;
    }
    
    (function initCategoriesProducts() {
        var sessionBackup = localStorage.getItem('rvts_perssearch_initializer');
        var parsedSessionBackup = JSON.parse(decodeURIComponent(sessionBackup));
        var backupDate = parsedSessionBackup ? parsedSessionBackup.date : null;
        if(!backupDate)sessionBackup = null;
        else {
            var now = new Date();
            now.setHours(0,0,0,0);
            var sessionBackupDate = new Date(backupDate);
            sessionBackupDate.setHours(0,0,0,0);
            var dayDiff = Math.round((now.getTime() - sessionBackupDate.getTime()) / (1000*60*60*24));
            if(dayDiff >= 1)
                sessionBackup = null;
        }
        if(!sessionBackup) {
            fetch('https://'+rcp_link+'/rrcp/imc/perssearch/Search.jsp',
            {
                method:'POST',
                headers: {
                'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'
                },
                body:'sCustId='+custId+'&search_param='+JSON.stringify(search_request_object)
            }).then(resp => resp.json()).then(resp => {
                resp.date = new Date();
                localStorage.setItem('rvts_perssearch_initializer',encodeURIComponent(JSON.stringify(resp)));
                categories.update(resp.categoryList);
                backupProductList = resp.productList;
                //backupProductList = backupProductList.filter((e,index) => index < searchConfig.resultLimit);
                backupProductList = backupProductList.map(convertProductFormat);
            });
        } else {
            setTimeout(function() {
                sessionBackup = decodeURIComponent(sessionBackup);
                var resp = JSON.parse(sessionBackup);
                categories.update(resp.categoryList);
                backupProductList = resp.productList;
                //backupProductList = backupProductList.filter((e,index) => index < searchConfig.resultLimit);
                backupProductList = backupProductList.map(convertProductFormat);
            },1);
        }
    })();
    

    function searchProducts(query, preserveCategories) {
        var originalQuery = query; 
        query = query.toLowerCase();
        searchConfig.synonyms.forEach(synonym => {
            query = replaceWord(query,synonym.original.toLowerCase(),synonym.synonym.toLowerCase());
        });
        search_request_object.searchParam = query.split('&').join(encodeURIComponent('&'));
        //Petlebi specific code(965)
        if(custId==965 && search_request_object.searchParam.includes('-')) {
            search_request_object.searchParam = '\\' + search_request_object.searchParam.split('-').join('\\-');
        }
        var type = 'search';
        if(query.length < 2) {
            return psGetFallbackProducts().then(fallbackProducts => {
                if(fallbackProducts.length > 0) {
                    return {
                        results: fallbackProducts,
                        type: type,
                        modifiedQuery: query
                    };
                } else {
                    var recentlyViewed = psGetProductsFromCookie();
                    type = 'recently';
                    return {
                        results: recentlyViewed,
                        type: type,
                        modifiedQuery: query
                    };
                }
            });
        }
        var fetchStart = new Date();
        return fetch('https://'+rcp_link+'/rrcp/imc/perssearch/Search.jsp',
        {
            method:'POST',
            headers: {
            'Content-Type':'application/x-www-form-urlencoded; charset=UTF-8'
            },
            body:'sCustId='+custId+'&search_param='+JSON.stringify(search_request_object)
        }).then(resp => resp.json())
        .then(resp => {
            var fetchEnd = new Date();
            if(typeof rvtsPersSearchDebug !== 'undefined' && rvtsPersSearchDebug === true) {
                console.log('Request for \''+query+'\' took ' + (fetchEnd.getTime() - fetchStart.getTime()) + 'ms.');
                console.log('Response: ', resp);
            }
            var categoryList = resp.categoryList;
            var searchResults = resp.productList;
            resultCount = searchResults.length;
            //searchResults = searchResults.filter((e,index) => index < searchConfig.resultLimit);
            searchResults = searchResults.map(convertProductFormat);
            if(searchResults.length === 0) {
                return psGetFallbackProducts().then(fallbackProducts => {
                    if(fallbackProducts.length > 0) {
                        return {
                            results: fallbackProducts,
                            type: type,
                            modifiedQuery: query
                        };
                    } else {
                        var recentlyViewed = psGetProductsFromCookie();
                        type = 'recently';
                        return {
                            results: recentlyViewed,
                            type: type,
                            modifiedQuery: query
                        };
                    }
                });
            }
            if(!preserveCategories) {
                categories.update(categoryList);
            }
            return {
                results: searchResults,
                type: type,
                modifiedQuery: query
            };
        });
    }
    
    function psGetCookie(cname) {
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

    function psSetCookie(name,value,days,ckie_dmn) {
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
        var recentProducts = psGetCookie(cName);
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
            psSetCookie(cName,encodeURIComponent(JSON.stringify(products)),10,hname);
        }
        else if(decodedProducts === recentProducts) {
            psSetCookie(cName,encodeURIComponent(recentProducts),10,hname);
        }
    })();
    
    function savePersSource() {
        psSetCookie('revotas_source','other',7,hname);
        psSetCookie('revotas_medium','perssearch',7,hname);
        psSetCookie('revotas_campaign','perssearch',7,hname);
    }
    
    function saveActivity(keyword, custId,activityType,link) {
        var activityURL = link ? link : window.location.href;
        var rvtsUserId = psGetCookie('revotas_web_push_user');
        var rvtsToken = psGetCookie('rvts_token');
        var rvtsEmail = psGetCookie('rvts_email');
        var fetchParams = 'cust_id='+custId+'&activity_type='+activityType+'&user_agent='+navigator.userAgent+'&session_id='+rvtsSessionId+'&search_result_count='+resultCount;
        if(rvtsUserId)fetchParams += '&user_id=' + rvtsUserId;
        if(rvtsToken)fetchParams += '&token=' + rvtsToken;
        if(rvtsEmail)fetchParams += '&email=' + rvtsEmail;
        fetchParams += '&url='+activityURL;
        fetch('https://f.revotas.com/frm/perssearch/save_perssearch_activity.jsp?' + fetchParams, {
            method:'POST',
            headers: {
                    'Content-Type':'application/json'
                },
            body: keyword
        });
    }
    
    function saveLastSearch(value) {
        value=value.trim();
        value=value.toLowerCase();
        value=encodeURIComponent(value);
        if(value==='')
            return;
        var cname = 'rvts_ps_search_list';
        var searchHistory = psGetCookie(cname);
        if(searchHistory) {
            searchHistory = JSON.parse(searchHistory);
            if(searchHistory.indexOf(value) === -1)searchHistory.unshift(value);
            if(searchHistory.length>6)searchHistory.length=6;
            psSetCookie(cname,JSON.stringify(searchHistory),10,hname);
        } else {
            psSetCookie(cname,JSON.stringify([value]),10,hname);
        }
    }
    
    function psSaveProductsToCookie(product) {
		product.date = new Date();
        var cName = 'rvts_product_history_array';
        var cookieProductList = decodeURIComponent(psGetCookie(cName));
        if(cookieProductList) {
            localStorage.setItem(cName,encodeURIComponent(cookieProductList));
            psSetCookie(cName,'',-1,hname);
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
    
    var fallbackProductList = [];
    var fallbackFetched = false;
    
    function psGetFallbackProducts() {
        if(!fallbackFetched) {
            if(searchConfig.fallbackScenario) {
                var sessionBackup = localStorage.getItem('rvts_perssearch_fallback');
                var parsedSessionBackup = JSON.parse(decodeURIComponent(sessionBackup));
                var backupDate = parsedSessionBackup ? parsedSessionBackup.date : null;
                if(!backupDate)sessionBackup = null;
                else {
                    var now = new Date();
                    now.setHours(0,0,0,0);
                    var sessionBackupDate = new Date(backupDate);
                    sessionBackupDate.setHours(0,0,0,0);
                    var dayDiff = Math.round((now.getTime() - sessionBackupDate.getTime()) / (1000*60*60*24));
                    if(dayDiff >= 1)
                        sessionBackup = null;
                }
                if(!sessionBackup) {
                    var campType = searchConfig.fallbackScenario;
                    return fetch('https://'+rcp_link+'/rrcp/imc/recommendation/get_recommendation.jsp?cust_id='+custId+'&type='+campType)
                    .then(resp => resp.json())
                    .then(resp => {
                        var backupObj = {productList: resp, date: new Date()};
                        localStorage.setItem('rvts_perssearch_fallback',encodeURIComponent(JSON.stringify(backupObj)));
                        resp = resp.filter(element => element!=null);
                        resp = resp.map(element => element[0]);
                        //resp = resp.filter((element, index) => index < searchConfig.resultLimit);
                        fallbackFetched = true;
                        fallbackProductList = resp;
                        return resp;
                    }).catch(() => {
                        localStorage.setItem('rvts_perssearch_fallback',encodeURIComponent(JSON.stringify({productList: [], date: new Date()})));
                        fallbackFetched = true;
                        fallbackProductList = [];
                        return [];
                    });
                } else {
                    return new Promise((resolve,reject)=>{
                        sessionBackup = decodeURIComponent(sessionBackup);
                        var backupObj = JSON.parse(sessionBackup);
                        var resp = backupObj.productList;
                        resp = resp.filter(element => element!=null);
                        resp = resp.map(element => element[0]);
                        //resp = resp.filter((element, index) => index < searchConfig.resultLimit);
                        fallbackFetched = true;
                        fallbackProductList = resp;
                        resolve(resp);
                    });
                }
            } else {
                localStorage.setItem('rvts_perssearch_fallback',encodeURIComponent(JSON.stringify({productList: [], date: new Date()})));
                fallbackFetched = true;
                fallbackProductList = [];
                return new Promise((resolve,reject) => resolve([]));
            }
        } else {
            return new Promise((resolve,reject) => resolve(fallbackProductList));
        }
    }
    
    function psGetProductsFromCookie() {
        var cName = 'rvts_product_history_array';
        var products = decodeURIComponent(psGetCookie(cName));
        if(products) {
            localStorage.setItem(cName,encodeURIComponent(products));
            psSetCookie(cName,'',-1,hname);
        } else {
            products = localStorage.getItem(cName) ? decodeURIComponent(localStorage.getItem(cName)) : null;
        }
        if(products) {
            products = JSON.parse(products);
            //products = products.filter((e,index) => index < searchConfig.resultLimit);
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
			products = products.map(e => e[0]);
			if(products.length>0)
				return products;
			else
				return backupProductList || [];
        } else 
            return backupProductList || [];
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
        psSaveProductsToCookie(product);
    } else if(window['productDetailModel']) {
        var currentProduct = productDetailModel;
        var product = {};
        product.p_id = currentProduct.productId;
        product.category_id = currentProduct.productCategoryId;
        product.name = currentProduct.productName;
        product.image_link = (currentProduct.productImages[0].imagePath.indexOf('https:')!==0 ? window.location.origin : '') + currentProduct.productImages[0].imagePath;
        product.product_price = currentProduct.productPriceKDVIncluded.toFixed(2) + ' ' + currentProduct.productCurrency;
        product.link = window.location.href;
        psSaveProductsToCookie(product);
    }
    
    var title = (function psTitle(t) {
        var title = document.createElement('div');
        title.classList.add('rvts_personalized_search-results-title');
        title.innerHTML = '<span>' + t + '</span>';
        return {
            element: title,
            update: (t) => {
                title.innerHTML = '<span>' + t + '</span>';
            },
            show: () => {
                title.style.display = '';
            },
            hide: () => {
                title.style.display = 'none';
            }
        }
    })(searchConfig.title);
    
    
    var lastSearch = {};
    
    if(searchConfig.showLastSearch == 1) {
        lastSearch = (function psLastSearch() {
            var lastSearch = document.createElement('div');
            lastSearch.classList.add('rvts_personalized_search_main-last-search');
            lastSearch.innerHTML = '<div>' + searchConfig.lastSearchTitle + '</div>';

            var lastSearchCookie = psGetCookie('rvts_ps_search_list');
            if(lastSearchCookie) lastSearchCookie = JSON.parse(lastSearchCookie);
            else lastSearch.style.display = 'none';
            lastSearch.innerHTML = '<div>' + searchConfig.lastSearchTitle + '</div>';
            if(lastSearchCookie) {
                lastSearchCookie.forEach(keyword => {
                    try {
                        keyword = decodeURIComponent(keyword);
                    } catch(e) {}
                    var href = document.createElement('a');
                    href.href = '/' + searchConfig.queryPattern.split('<_Query_>').join(keyword);
                    href.innerText = keyword;
                    href.classList.add('rvts_personalized_search_main-last-search-item');
                    mouseEnterWithDelay(href, () => {
                        input.value = keyword;
                        searchProducts(keyword,true).then(returnedProducts => {
                            var results = returnedProducts.results;
                            var type = returnedProducts.type;
                            renderResults(results,true);
                            if(type==='search') {
                                title.update(searchConfig.title);
                                footer.hide();
                            } else if(type==='recently') {
                                title.update(searchConfig.recentlyViewedTitle);
                                footer.hide();
                            }
                            footer.hide();
                        });
                    }, 500);
                    href.addEventListener('mouseup', e => {
                        if(e.which === 1 || e.which === 2) {
                            saveLastSearch(keyword);
                            saveActivity(keyword,custId,ACTIVITY_SEARCH);
                        }
                    });
                    lastSearch.appendChild(href);
                });
            }

            return {
                element: lastSearch,
                show: () => {
                    lastSearch.style.display = '';
                },
                hide: () => {
                    lastSearch.style.display = 'none';
                }
            };
        })();
    }
    
    var categories = (function psCategories() {
        var categories = document.createElement('div');
        categories.classList.add('rvts_personalized_search_main-categories');
        categories.innerHTML = '<div>' + searchConfig.categoriesTitle + '</div>';
        searchConfig.categories.forEach((category, index) => {
            if(index>=searchConfig.categoriesLimit)
                return;
            var href = document.createElement('a');
            href.href = category.link;
            href.innerText = category.name;
            href.classList.add('rvts_personalized_search_main-categories-item');
            categories.appendChild(href);
        });
        return {
            element: categories,
            show: () => {
                categories.style.display = '';
            },
            hide: () => {
                categories.style.display = 'none';
            },
            update: (categoryList) => {
                if(categoryList.length === 0)
                    return;
                var categoryListString = categoryList.map(e=>e.categoryName.toLowerCase());
                categories.innerHTML = '<div>' + searchConfig.categoriesTitle + '</div>';
                var limitCounter = 0;
                searchConfig.categories.forEach((category, index) => {
                    if((limitCounter>=searchConfig.categoriesLimit || !categoryListString.includes(category.name.toLowerCase())) && category.pinned == 0)
                        return;
                    var href = document.createElement('a');
                    href.href = category.link;
                    href.innerText = category.name;
                    href.classList.add('rvts_personalized_search_main-categories-item');
                    if(categoryListString.indexOf(category.name.toLowerCase()) != -1) {
                        mouseEnterWithDelay(href, () => {
                            var productList = categoryList[categoryListString.indexOf(category.name.toLowerCase())].productList;
                            if(productList.length > 0) {
                                productList = productList.map(convertProductFormat);
                                //productList = productList.filter((e,idx) => idx < searchConfig.resultLimit);
                                renderResults(productList,true);
                                title.update(searchConfig.title);
                                footer.hide();
                            }
                        }, 500);
                    } else {
                        mouseEnterWithDelay(href, () => {
                            searchProducts(category.name,true).then(returnedProducts => {
                                var results = returnedProducts.results;
                                var type = returnedProducts.type;
                                renderResults(results,true);
                                if(type==='search') {
                                    title.update(searchConfig.title);
                                    footer.hide();
                                } else if(type==='recently') {
                                    title.update(searchConfig.recentlyViewedTitle);
                                    footer.hide();
                                }
                                footer.hide();
                            });
                        }, 500)
                    }
                    categories.appendChild(href);
                    if(category.pinned==0)limitCounter++;
                });
            },
            list: searchConfig.categories
        };
    })();
    
    var recommendedQueries = (function psCategories() {
        var recommendedQueries = document.createElement('div');
        recommendedQueries.classList.add('rvts_personalized_search_main-recommended-queries');
        recommendedQueries.innerHTML = '<div>' + searchConfig.recommendedQueriesTitle + '</div>';
        searchConfig.recommendedQueries.forEach(keyword => {
            var href = document.createElement('a');
            href.href = '/' + searchConfig.queryPattern.split('<_Query_>').join(keyword);
            href.innerText = keyword;
            href.classList.add('rvts_personalized_search_main-recommended-queries-item');
            mouseEnterWithDelay(href, () => {
                input.value = keyword;
                searchProducts(keyword,true).then(returnedProducts => {
                    var results = returnedProducts.results;
                    var type = returnedProducts.type;
                    renderResults(results,true);
                    if(type==='search') {
                        title.update(searchConfig.title);
                        footer.update(keyword, returnedProducts.modifiedQuery);
                    } else if(type==='recently') {
                        title.update(searchConfig.recentlyViewedTitle);
                        footer.hide();
                    }
                    footer.hide();
                });
            }, 500);
            href.addEventListener('mouseup', e => {
                if(e.which === 1 || e.which === 2) {
                    saveLastSearch(keyword);
                    saveActivity(keyword,custId,ACTIVITY_SEARCH);
                }
            });
            recommendedQueries.appendChild(href);
        });
        return {
            element: recommendedQueries,
            show: () => {
                recommendedQueries.style.display = '';
            },
            hide: () => {
                recommendedQueries.style.display = 'none';
            },
            list: searchConfig.recommendedQueries
        };
    })();
    
    var footer = (function psFooter() {
        var searchLink = document.createElement('a');
        searchLink.addEventListener('mouseup', e => {
            if(e.which === 1 || e.which === 2) {
                saveLastSearch(e.target.getAttribute('keyword'));
                saveActivity(e.target.getAttribute('keyword'),custId,ACTIVITY_SEARCH);
            }
        });
        var footer = document.createElement('div');
        footer.classList.add('rvts_personalized_search-results-footer');
        footer.appendChild(searchLink);
        return {
            element: footer,
            show: () => {
                footer.style.display = '';
            },
            hide: () => {
                footer.style.display = 'none';
            },
            update: (t,m) => {
                if(!t) {
                    footer.style.display = 'none';
                } else {
                    if(currencyConfig && currencyConfig.search_text) {
                        searchLink.innerText = currencyConfig.search_text.split('<_Query_>').join(t);
                    } else {
                        searchLink.innerText = t + " için tüm sonuçları göster";
                    }
                    searchLink.setAttribute('keyword',t);
                    searchLink.href = '/' + searchConfig.queryPattern.split('<_Query_>').join((m?m:t).toLowerCase());
                    footer.style.display = '';
                }
            },
            updateLink: (link) => {
                searchLink.href = link;
                footer.style.display = '';
            }
        };
    })();
    
    var results = (function psResults() {
        var results = document.createElement('div');
        results.classList.add('rvts_personalized_search-results');
        return {
            element: results,
            show: () => {
                results.style.display = '';
            },
            hide: () => {
                results.style.display = 'none';
            }
        };
    })(); 
    
    if(submitButton) {
        var old_submit_element = submitButton;
        var new_submit_element = old_submit_element.cloneNode(true);
        old_submit_element.parentNode.replaceChild(new_submit_element, old_submit_element);
        submitButton = new_submit_element;

        submitButton.onclick = null;
        submitButton.addEventListener('click', function(e) {
            e.preventDefault();
            var query = input.value.trim().toLowerCase();
            if(query==='')return;
            saveLastSearch(query);
            saveActivity(query,custId,ACTIVITY_SEARCH);
            var redirectUrl = '/' + searchConfig.queryPattern.split('<_Query_>').join(query);
            searchConfig.redirects.forEach(e => {
                if(e.query.toLowerCase() === query) {
                    var tempURL = new URL(e.link);
                    redirectUrl = e.link;
                    if(!searchConfig.appendUTM || searchConfig.appendUTM == 1) {
                        if(tempURL.search)redirectUrl+='&';
                        else redirectUrl+='?';
                        redirectUrl += 'utm_source=revotas&utm_medium=perssearch&utm_campaign=perssearch&rvs_source=other&rvs_medium=perssearch&rvs_campaign=perssearch';
                    }
                    savePersSource();
                }
            });
            window.location = redirectUrl;
        });
    }
    
    
    var old_element = input;
    var new_element = old_element.cloneNode(true);
    old_element.parentNode.replaceChild(new_element, old_element);
    input = new_element;

    input.onkeydown = null;
    input.onkeypress = null;
    input.onkeyup = null;
    input.autocomplete = 'off';
    input.addEventListener('keypress', e => {
        if(e.key === 'Enter') {
            e.preventDefault();
            var query = e.target.value.trim().toLowerCase();
            if(query==='')return;
            saveLastSearch(query);
            saveActivity(query,custId,ACTIVITY_SEARCH);
            var redirectUrl = '/' + searchConfig.queryPattern.split('<_Query_>').join(query);
            searchConfig.redirects.forEach(e => {
                if(e.query.toLowerCase() === query) {
                    var tempURL = new URL(e.link);
                    redirectUrl = e.link;
                    if(!searchConfig.appendUTM || searchConfig.appendUTM == 1) {
                        if(tempURL.search)redirectUrl+='&';
                        else redirectUrl+='?';
                        redirectUrl += 'utm_source=revotas&utm_medium=perssearch&utm_campaign=perssearch&rvs_source=other&rvs_medium=perssearch&rvs_campaign=perssearch';
                    }
                    savePersSource();
                }
            });
            window.location = redirectUrl;
        }
    });
    
    var mainDiv = null;
    
    var resultList = {};
    
    var filterPanel = document.createElement('div');
    filterPanel.classList.add('rvts_personalized_search_main-filter-element-list');
    
    mainDiv = (function createSearchUI() {
        var filterConfigs = searchConfig.filterConfigs;
        
        var newDiv = document.createElement('div');
        newDiv.classList.add('rvts_personalized_search_main');
        newDiv.style.position = 'absolute';
        newDiv.style.zIndex = maxZIndex - 2;
        newDiv.style.display = 'none';
        
        var leftPanel = document.createElement('div');
        leftPanel.classList.add('rvts_personalized_search_main-left-panel');
        
        if(searchConfig.showLastSearch == 1)
            leftPanel.appendChild(lastSearch.element);

        if(categories.list.length>0)leftPanel.appendChild(categories.element);
        
        if(recommendedQueries.list.length>0)leftPanel.appendChild(recommendedQueries.element);
        
        for(var key in filterConfigs) {
            var filterConfig = filterConfigs[key];
            if(filterConfig.enabled && 
               ((filterConfig.list && filterConfig.list.length > 0) || 
                (filterConfig.range && filterConfig.range.length === 2))
              ) {
                leftPanel.appendChild(filterBox.createFilter(filterConfig).element);
            }
        }
        
        filterBox.subscribe(filterList => {
            search_request_object = {
                sortParam : sortParam,
                searchParam: ''
            };
            filterPanel.innerHTML = '';
            filterList.forEach(filter => {
                var filterValues = filter.getValues();
                if(!filterValues)return;
                if(filterValues.name === 'product_price') {
                    search_request_object.priceMin = filterValues.range[0];
                    search_request_object.priceMax = filterValues.range[1];
                } else if(filterValues.name === 'top_category_id' ||
                         filterValues.name === 'category_id_2' ||
                         filterValues.name === 'category_id_3' ||
                         filterValues.name === 'category_id_4') {
                    if(!search_request_object.categories)search_request_object.categories=[];
                    search_request_object.categories = filterValues.list.map(el => {
                        return {categoryName: el.string, categoryType: el.meta};
                    })
                }
                else {
                    search_request_object[filterValues.name] = filterValues.list.map(el => el.string);
                }
                filter.getFilters().forEach(filterDiv => {
                    filterPanel.appendChild(filterDiv);
                });
            });
            searchKeyword(input.value);
        });
        
        var rightPanel = document.createElement('div');
        rightPanel.classList.add('rvts_personalized_search_main-right-panel');
        
        rightPanel.appendChild(filterPanel);
        
        rightPanel.appendChild(title.element);
        
        rightPanel.appendChild(results.element);
        
        rightPanel.appendChild(footer.element);

        newDiv.appendChild(leftPanel);
        newDiv.appendChild(rightPanel);
        
        document.body.appendChild(newDiv);
        
        return newDiv;
    })();
    
    function getScrollTop() {
        var h = document.documentElement,
            b = document.body,
            st = 'scrollTop',
            sh = 'scrollHeight';
        return h[st]||b[st];
    }
    
    var searchUIShown = false;
    
    function showSearchUI() {
        if(searchUIShown)
            return;
        var inputClientRect = input.getBoundingClientRect();
        var inputBottom = inputClientRect.bottom;
        var inputLeft = inputClientRect.left;
        var inputTop = inputClientRect.top;
        mainDiv.style.top = (inputBottom + getScrollTop() + 10) + 'px';
        mainDiv.style.left = inputLeft + 'px';
        mainDiv.style.visibility = 'hidden';
        mainDiv.style.display = '';
        document.body.appendChild(mainDiv);
        var mainDivProps = mainDiv.getBoundingClientRect();
        if((mainDivProps.width + mainDivProps.left) > screen.width) {
            mainDiv.style.left = '';
            mainDiv.style.right = '0px';
        }
        mainDiv.style.visibility = '';
        searchUIShown = true;
    }
    
    function hideSearchUI() {
        if(!searchUIShown)
            return;
        mainDiv.remove();
        searchUIShown = false;
    }

    document.addEventListener('scroll', () => {
        if(getComputedStyle(mainDiv).display === '')return;
        var inputClientRect = input.getBoundingClientRect();
        var inputBottom = inputClientRect.bottom;
        var inputLeft = inputClientRect.left;
        
        mainDiv.style.top = (inputBottom + getScrollTop() + 10) + 'px';
    });
    
    function renderResult(product) {
        if(resultList[product.p_id])
            return resultList[product.p_id];
        var result = document.createElement('a');
        result.classList.add('rvts_personalized_search-result');
        result.href = product.link;
        if(!searchConfig.appendUTM || searchConfig.appendUTM == 1) {
            result.href += '?utm_source=revotas&utm_medium=perssearch&utm_campaign=perssearch&rvs_source=other&rvs_medium=perssearch&rvs_campaign=perssearch';
        }
        result.setAttribute('originalHref',product.link);
        result.addEventListener('mouseup', function(e) {
            if(e.which === 1 || e.which === 2) {
                savePersSource();
                saveLastSearch(input.value);
                saveActivity(input.value,custId,ACTIVITY_CLICK,this.getAttribute('originalHref'));
            }
        })
        var originalImageLink = product.image_link;
        var modifiedImageLink = product.image_link.replace('-B.','-K.');
        var image = document.createElement('img');
        var imageErrorFn = function() {
            this.src=originalImageLink;
            image.removeEventListener('error',imageErrorFn);
        }
        image.addEventListener('error', imageErrorFn);
        image.src = modifiedImageLink;
        var name = document.createElement('div');
        name.innerHTML = product.name;
        var priceDiv = document.createElement('div');
        var price = document.createElement('span');
        price.innerText = currencyConfig ? formatCurrency(product.product_price, currencyConfig) : product.product_price;
        var sales_price = product.product_sales_price;
        var salesPrice = null;
        var dash = document.createElement('span');
        dash.innerText = ' - ';
        if(sales_price) {
            if(currencyConfig)sales_price = formatCurrency(sales_price, currencyConfig);
            salesPrice = document.createElement('span');
            salesPrice.innerText = sales_price;
            price.classList.add('original-price');
            salesPrice.classList.add('sales-price');
        }
        result.appendChild(image);
        result.appendChild(name);
        if(!salesPrice) {
            dash.classList.add('rvts_personalized_search-dash');
            priceDiv.appendChild(dash);
        }
        priceDiv.appendChild(price);
        if(salesPrice){
            dash.classList.add('rvts_personalized_search-sales-price-dash');
            priceDiv.appendChild(dash);
            priceDiv.appendChild(salesPrice);
        }
        result.appendChild(priceDiv);
        result.appendChild(document.createElement('div'));
        resultList[product.p_id] = result;
        return result;
    }
    
    function renderResults(products,preserve) {
        if(!products)
            return;
        if(products.length>0)showSearchUI();
        else if(products.length === 0 && preserve) {
            showSearchUI();
            title.hide();
            results.hide();
            footer.hide();
            return;
        }
        else {
            hideSearchUI();
            return;
        }
        title.show();
        results.show();
        footer.show();
        var resultsDiv = results.element;
        Array.from(resultsDiv.children).forEach(e => e.remove());
        products = products.filter((e,i,arr)=>arr.findIndex(p=>p.image_link===e.image_link)===i).filter((e,i)=>i<searchConfig.resultLimit);
        products = products.map(renderResult);
        products.forEach(product => resultsDiv.appendChild(product));
    }
    
    function searchKeyword(value) {
        searchProducts(value).then(returnedProducts => {
            var results = returnedProducts.results;
            var type = returnedProducts.type;
            renderResults(results,true);
            if(type==='search') {
                title.update(searchConfig.title);
                footer.update(value, returnedProducts.modifiedQuery);
            } else if(type==='recently') {
                title.update(searchConfig.recentlyViewedTitle);
                footer.hide();
            }
        })
    }
    
    var keyUtil = keyReleaseUtil(searchKeyword);
    
    var lastInputValue = null;
    
    input.addEventListener('click', e => {
        keyUtil.hit();
        keyUtil.release(e.target.value);
    });
    
    input.addEventListener('keyup', e => {
        var value = e.target.value.trim();
        if(lastInputValue === value)
            return;
        keyUtil.hit();
        keyUtil.release(value);
        lastInputValue = value;
    });
    
    document.addEventListener('click', e => {
        var inputRect = input.getBoundingClientRect();
        var mainDivRect = mainDiv.getBoundingClientRect();
        
        var inputLeft = inputRect.left;
        var inputWidth = inputRect.width;
        var inputTop = inputRect.top;
        var inputHeight = inputRect.height;
        
        var mainDivLeft = mainDivRect.left;
        var mainDivWidth = mainDivRect.width;
        var mainDivTop = mainDivRect.top;
        var mainDivHeight = mainDivRect.height;
        
        var clientX = e.clientX;
        var clientY = e.clientY;
        if(!(((inputLeft <= clientX && (inputLeft + inputWidth) >= clientX) &&
          (inputTop <= clientY && (inputTop + inputHeight) >= clientY)) ||
          ((mainDivLeft <= clientX && (mainDivLeft + mainDivWidth) >= clientX) &&
          (mainDivTop <= clientY && (mainDivTop + mainDivHeight) >= clientY)))) {
            hideSearchUI();
        }
            
    });
    
}