if (window.location.href.includes("?blocked1")) {
    function swLoadFunction() {
      console.log("sw load");
      var __smartWidgetFunctions__ = [];
      var __smartWidgetConditionFunctions__ = {};
  
      var hname = window.location.hostname;
  
      if (hname.substr(0, 3) == "www") {
        hname = hname.substring(3, hname.length);
      }
  
      function generateSessionId() {
        return [...Array(30)]
          .map((i) => (~~(Math.random() * 36)).toString(36))
          .join("");
      }
  
      function rvtsPushGaEvent(type, popupName) {
        if (!popupName || !popupName.trim()) return;
        var event = "";
        try {
          if (type == 0) event = "SW - " + popupName + " - View";
          if (type == 1) event = "SW - " + popupName + " - Click";
          if (type == 2) event = "SW - " + popupName + " - Submit";
          if (typeof ga === "function" && typeof ga.getAll === "function") {
            if (type == 0) {
              ga.getAll()[0].send("event", "Revotas", event, {
                nonInteraction: true,
              });
            } else {
              ga.getAll()[0].send("event", "Revotas", event);
            }
          } else if (typeof gtag === "function") {
            if (type == 0) {
              gtag("event", "play", {
                eventCategory: "Revotas",
                eventLabel: event,
                non_interaction: true,
              });
            } else {
              gtag("event", "play", {
                eventCategory: "Revotas",
                eventLabel: event,
              });
            }
          } else if (_hjSettings.scriptSource === "gtm") {
            window.dataLayer = window.dataLayer || [];
            if (type == 0) {
              window.dataLayer.push({
                event: "event",
                eventLabel: event,
                eventCategory: "Revotas",
                non_interaction: true,
              });
            } else {
              window.dataLayer.push({
                event: "event",
                eventLabel: event,
                eventCategory: "Revotas",
              });
            }
          }
        } catch (err) {
          console.warn("rvtsPushGaEvent error:", err);
        }
      }
  
      var rvtsSessionId = null;
  
      var swSessionIdResolver = null;
      var swSessionId = new Promise((resolve, reject) => {
        swSessionIdResolver = resolve;
        if (sessionStorage.getItem("rvts_session_id"))
          resolve(sessionStorage.getItem("rvts_session_id"));
      });
  
      swSessionId.then(function (sessionId) {
        rvtsSessionId = sessionId;
        sessionStorage.setItem("rvts_session_id", sessionId);
      });
  
      var rvtsSessionIdSet = false;
      window.addEventListener("storage", function (e) {
        if (e.key === "get_rvts_session_id" && e.newValue) {
          var sessionId = sessionStorage.getItem("rvts_session_id");
          if (sessionId) {
            localStorage.setItem("rvts_local_session_id", sessionId);
            localStorage.removeItem("rvts_local_session_id");
          }
        }
        if (
          e.key === "rvts_local_session_id" &&
          e.newValue &&
          !rvtsSessionIdSet
        ) {
          sessionStorage.setItem("rvts_session_id", e.newValue);
          rvtsSessionIdSet = true;
          swSessionIdResolver(e.newValue);
        }
      });
  
      localStorage.setItem("get_rvts_session_id", "get");
      localStorage.removeItem("get_rvts_session_id");
      setTimeout(() => {
        swSessionIdResolver(generateSessionId());
      }, 250);
  
      var rvtsUserId = swGetCookie("revotas_web_push_user");
      var rvtsEmail = typeof email === "string" && email ? email : null;
  
      function rvtsPushSmartWidgetActivity(
        smartWidgetCallToActionButton,
        popupId,
        popupName,
        aType
      ) {
        var currentPopup = rvtsSmartWidgetList[popupId];
  
        if ((smartWidgetCallToActionButton || aType != null) && currentPopup) {
          var custId = currentPopup.custId;
          var formId = currentPopup.formId;
          if (!formId) formId = 0;
          var activityType = smartWidgetCallToActionButton
            ? smartWidgetCallToActionButton.getAttribute("activity_type")
            : aType;
          if (activityType == "click") activityType = "1";
          else if (activityType == "submit") activityType = "2";
          var fetchParams = "";
          fetchParams += "cust_id=" + custId;
          fetchParams += "&popup_id=" + popupId;
          fetchParams += "&form_id=" + formId;
          fetchParams += "&user_agent=" + navigator.userAgent;
          fetchParams += "&activity_type=" + activityType;
          fetchParams += "&session_id=" + rvtsSessionId;
          if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
          if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
          if (/Mobi|Android/i.test(navigator.userAgent)) {
            fetchParams += "&device=" + "1"; //mobile
          } else {
            fetchParams += "&device=" + "2"; //desktop
          }
          fetchParams +=
            "&url=" +
            window.location.href.split("&").join(encodeURIComponent("&"));
  
          fetch(
            "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
              fetchParams
          );
          rvtsPushGaEvent(activityType, popupName);
          if (activityType == "1") saveSwSource(popupId);
        }
      }
  
      function rvtsLaunchWidget(widgetId) {
        if (typeof rvtsSmartWidgetList === "undefined") return;
        var popup = rvtsSmartWidgetList[widgetId];
        if (!popup.show) return;
        var popupId = popup.popupId;
        var formId = popup.formId;
        var custId = popup.custId;
        var params = popup.params;
        popup.show(false, custId, popupId, formId);
        try {
          if (params.scriptCode)
            eval("(function(){" + params.scriptCode + "}).call(popup);");
        } catch (err) {
          console.warn(params.scriptCode);
          console.warn("There was an error with the above smartwidget script");
          console.warn("Smartwidget ID: " + popupId);
          console.warn(err);
        }
      }
  
      function rvtsWaitFor(callback) {
        var requestAnimFrame = (function () {
          return (
            window.requestAnimationFrame ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame ||
            window.oRequestAnimationFrame ||
            window.msRequestAnimationFrame ||
            function (callback) {
              window.setTimeout(callback, 1000 / 60);
            }
          );
        })();
  
        var promiseFulfilled = false;
        var resolver = null;
        var rejecter = null;
        var promise = new Promise(function (resolve, reject) {
          resolver = resolve;
          rejecter = reject;
        });
        promise.then(function () {
          promiseFulfilled = true;
        });
        promise.catch(function (err) {
          promiseFulfilled = true;
          console.error(err);
        });
  
        function loopFunction() {
          if (!promiseFulfilled) {
            callback(resolver, rejecter);
            requestAnimFrame(loopFunction);
          }
        }
        loopFunction();
  
        return promise;
      }
  
      function rvtsAddScript(scriptLink) {
        if (!scriptLink) return;
        var scriptTag = document.createElement("script");
        var resolver = null;
        var p = new Promise((resolve, reject) => {
          resolver = resolve;
        });
        scriptTag.type = "text/javascript";
        scriptTag.onload = function () {
          resolver(scriptTag);
        };
        scriptTag.onerror = function () {
          resolver();
        };
        scriptTag.src = scriptLink;
        document.head.appendChild(scriptTag);
        return p;
      }
  
      function swGetCookie(cname) {
        var name = cname + "=";
        var decodedCookie = document.cookie;
        var ca = decodedCookie.split(";");
        for (var i = 0; i < ca.length; i++) {
          var c = ca[i];
          while (c.charAt(0) == " ") {
            c = c.substring(1);
          }
          if (c.indexOf(name) == 0) {
            return c.substring(name.length, c.length);
          }
        }
        return "";
      }
  
      function swSetCookie(name, value, days, ckie_dmn) {
        var expires = "";
        if (days) {
          var date = new Date();
          date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000);
          expires = "; expires=" + date.toUTCString();
        }
        document.cookie =
          name +
          "=" +
          (value || "") +
          expires +
          ";domain=" +
          ckie_dmn +
          "; path=/";
      }
  
      var swSessionConfigResolver = null;
      var swSessionConfig = new Promise((resolve, reject) => {
        swSessionConfigResolver = resolve;
        if (
          typeof swSessionCacheDisabled !== "undefined" &&
          swSessionCacheDisabled === true
        )
          resolve(null);
        else if (sessionStorage.getItem("sw_session_config"))
          resolve(sessionStorage.getItem("sw_session_config"));
      });
  
      var swSessionConfigSet = false;
      window.addEventListener("storage", function (e) {
        if (e.key === "get_sw_session_config" && e.newValue) {
          var swConfig = sessionStorage.getItem("sw_session_config");
          if (swConfig) {
            localStorage.setItem("sw_local_config", swConfig);
            localStorage.removeItem("sw_local_config");
          }
        }
        if (e.key === "sw_local_config" && e.newValue && !swSessionConfigSet) {
          sessionStorage.setItem("sw_session_config", e.newValue);
          swSessionConfigSet = true;
          swSessionConfigResolver(e.newValue);
        }
      });
  
      localStorage.setItem("get_sw_session_config", "get");
      localStorage.removeItem("get_sw_session_config");
      setTimeout(() => {
        swSessionConfigResolver(null);
      }, 250);
  
      (function () {
        var shouldUpdate = false;
        var cName = "rvts_product_history_array";
        var recentProducts = swGetCookie(cName);
        if (!recentProducts) return;
        var decodedProducts = null;
        try {
          decodedProducts = decodeURIComponent(recentProducts);
        } catch (e) {
          decodedProducts = recentProducts;
        }
        var products = JSON.parse(decodedProducts);
        products = products.map((product) => {
          var p = product[0];
          var index = p.image_link.indexOf("https:", 1);
          if (index > 0) {
            shouldUpdate = true;
            p.image_link = p.image_link.substring(index, p.image_link.length);
          }
          return product;
        });
        if (shouldUpdate) {
          swSetCookie(
            cName,
            encodeURIComponent(JSON.stringify(products)),
            10,
            hname
          );
        } else if (decodedProducts === recentProducts) {
          swSetCookie(cName, encodeURIComponent(recentProducts), 10, hname);
        }
      })();
  
      function saveProductsToCookie(product) {
        var tempUrl = new URL(product.link);
        product.link = tempUrl.href.split(tempUrl.search).join("");
        product.date = new Date();
        var cName = "rvts_product_history_array";
        var cookieProductList = decodeURIComponent(swGetCookie(cName));
        if (cookieProductList) {
          localStorage.setItem(cName, encodeURIComponent(cookieProductList));
          swSetCookie(cName, "", -1, hname);
        } else {
          cookieProductList = localStorage.getItem(cName)
            ? decodeURIComponent(localStorage.getItem(cName))
            : null;
        }
        if (cookieProductList) {
          var productList = JSON.parse(cookieProductList);
          var tempArray = productList.filter(function (element) {
            return element[0].p_id == product.p_id;
          });
          if (tempArray.length == 0) {
            productList.unshift([product]);
          } else {
            productList = productList.map(function (element) {
              if (element[0].p_id == product.p_id) return [product];
              return element;
            });
          }
          if (productList.length > 10) productList.length = 10;
          localStorage.setItem(
            cName,
            encodeURIComponent(JSON.stringify(productList))
          );
        } else {
          var productList = [];
          productList.push([product]);
          localStorage.setItem(
            cName,
            encodeURIComponent(JSON.stringify(productList))
          );
        }
      }
  
      if (window["PRODUCT_DATA"] && PRODUCT_DATA.length == 1) {
        var currentProduct = PRODUCT_DATA[0];
        var product = {};
        product.p_id = currentProduct.id;
        product.category_id = currentProduct.category_ids;
        product.name = currentProduct.name;
        product.image_link = currentProduct.image;
        product.product_price =
          currentProduct.total_base_price.toFixed(2) +
          " " +
          currentProduct.currency;
        product.product_sales_price =
          currentProduct.total_sale_price.toFixed(2) +
          " " +
          currentProduct.currency;
        product.link = window.location.href;
        window["rvtsSWCurrentProduct"] = product;
        window["rvtsSWCurrentProduct"].stockCount = currentProduct.quantity;
        saveProductsToCookie(product);
      } else if (window["productDetailModel"]) {
        var currentProduct = productDetailModel;
        var product = {};
        var currency = currentProduct.productCurrency;
        var onSales = currentProduct.product.indirimliFiyati > 0 ? true : false;
        var sales_price = currentProduct.product.indirimliFiyatiStr
          ? currentProduct.product.indirimliFiyatiStr
              .split(".")
              .join("")
              .split(",")
              .join(".")
              .split("TL")
              .join(currency)
          : null;
        var price = currentProduct.product.satisFiyatiStr
          ? currentProduct.product.satisFiyatiStr
              .split(".")
              .join("")
              .split(",")
              .join(".")
              .split("TL")
              .join(currency)
          : null;
        product.p_id = currentProduct.productId;
        product.category_id = currentProduct.productCategoryId;
        product.name = currentProduct.productName;
        product.image_link =
          (currentProduct.productImages[0].imagePath.indexOf("https:") !== 0
            ? window.location.origin
            : "") + currentProduct.productImages[0].imagePath;
        if (onSales) product.product_sales_price = sales_price;
        product.product_price = price;
        product.link = window.location.href;
        window["rvtsSWCurrentProduct"] = product;
        window["rvtsSWCurrentProduct"].stockCount =
          currentProduct.totalStockAmount;
        saveProductsToCookie(product);
      } else if (
        document.querySelectorAll(".analytics-data").length > 1 &&
        typeof JSON.parse(
          document.querySelectorAll(".analytics-data")[1].innerHTML
        ).productDetail !== "undefined"
      ) {
        var currentProduct = JSON.parse(
          document.querySelectorAll(".analytics-data")[1].innerHTML
        ).productDetail.data;
        var product = {};
        product.p_id = currentProduct.dimension8;
        product.category_id = currentProduct.category;
        product.name = currentProduct.name;
        product.image_link = currentProduct.dimension19;
        product.product_price = currentProduct.price.toFixed(2) + " TL";
        product.link = window.location.href;
        if (parseFloat(currentProduct.dimension16.trim()) > 0) {
          product.product_sales_price = product.product_price;
          product.product_price =
            parseFloat(currentProduct.dimension16.trim()).toFixed(2) + " TL";
        }
        window["rvtsSWCurrentProduct"] = product;
        saveProductsToCookie(product);
      }
  
      function getInformation(inf) {
        var fields = inf.split(",");
        cstid = fields[0].trim();
        var img = fields[2];
        dmn = fields[3].trim();
        revotas_popup = fields[4].trim();
        cust_status = fields[1].trim();
  
        var native_flag = fields[5].trim();
        cookie_domain = fields[6].trim();
        cst_type = fields[7].trim();
  
        swSetCookie(
          "rvts_popup_inf",
          cstid +
            "," +
            cust_status +
            "," +
            native_flag +
            "," +
            cookie_domain +
            "," +
            cst_type,
          10,
          cookie_domain
        );
      }
  
      /*****************************
       ******************************
       *****************************/
  
      var maxInt = 2147483647;
  
      var SMART_WIDGET_MESSAGE = "smart_widget_message";
  
      function formatDate(date) {
        var day = date.getDate();
        var month = date.getMonth() + 1;
        var year = date.getFullYear();
        var time = month + "/" + day + "/" + year;
        return time;
      }
  
      function countVisitTime() {
        var cname = "rvts_user_browse_time";
        var cookieVisitTime = swGetCookie(cname);
        if (cookieVisitTime) {
          swSetCookie(cname, Number.parseInt(cookieVisitTime) + 1, 10, hname);
        } else {
          swSetCookie(cname, "0", 10, hname);
        }
        localStorage.setItem(SMART_WIDGET_MESSAGE, "counting");
        localStorage.removeItem(SMART_WIDGET_MESSAGE);
      }
  
      function saveLastPopupShow(popupId) {
        var cname = "rvts_popup_last_show";
        var time = formatDate(new Date());
        var obj;
        var cookieLastShow = swGetCookie(cname);
        if (cookieLastShow) {
          try {
            obj = JSON.parse(cookieLastShow);
            obj[popupId] = time;
            swSetCookie(cname, JSON.stringify(obj), 10, hname);
          } catch (e) {
            obj = {};
            obj[popupId] = time;
            swSetCookie(cname, JSON.stringify(obj), 10, hname);
          }
        } else {
          obj = {};
          obj[popupId] = time;
          swSetCookie(cname, JSON.stringify(obj), 10, hname);
        }
      }
  
      function saveVisitHistory() {
        var cname = "rvts_user_history_array";
        var storageVisitHistory = localStorage.getItem(cname);
        if (storageVisitHistory) {
          var historyArray = storageVisitHistory.split("|");
          if (!historyArray.includes(window.location.href.toLowerCase())) {
            historyArray.unshift(window.location.href.toLowerCase());
            localStorage.setItem(cname, historyArray.join("|"));
          }
        } else {
          var historyArray = [window.location.href.toLowerCase()];
          localStorage.setItem(cname, historyArray.join("|"));
        }
      }
  
      function saveVisitHistoryDate() {
        var currentPage = window.location.href.toLowerCase();
        var cname = "rvts_user_history_array_date";
        var storageVisitHistory = localStorage.getItem(cname);
        if (storageVisitHistory) {
          var historyArray = JSON.parse(storageVisitHistory);
          var index = historyArray.findIndex(function (element) {
            return element.link === currentPage;
          });
          if (index === -1)
            historyArray.push({ link: currentPage, date: new Date() });
          else historyArray[index].date = new Date();
          localStorage.setItem(cname, JSON.stringify(historyArray));
        } else {
          var historyArray = [];
          historyArray.push({ link: currentPage, date: new Date() });
          localStorage.setItem(cname, JSON.stringify(historyArray));
        }
      }
  
      var countingTime = false;
  
      if (!window["rvtsVisitCounter"]) {
        (function () {
          function listenToStorage() {
            return new Promise(function (resolve, reject) {
              var counter = 0;
              window.addEventListener(
                "storage",
                (fn = function (e) {
                  if (
                    e.key === SMART_WIDGET_MESSAGE &&
                    !e.oldValue &&
                    e.newValue === "counting"
                  ) {
                    resolve(e.newValue);
                    window.removeEventListener("storage", fn);
                  }
                })
              );
              setTimeout(function () {
                reject("response timeout");
                window.removeEventListener("storage", fn);
              }, 1000);
            });
          }
  
          var questionInterval = setInterval(function () {
            listenToStorage().catch(function () {
              if (countingTime) return;
              clearInterval(questionInterval);
              countVisitTime();
              window["rvtsVisitCounter"] = setInterval(
                countVisitTime,
                1000,
                hname
              );
              countingTime = true;
            });
          }, 5000);
        })();
      }
  
      saveVisitHistory();
      saveVisitHistoryDate();
  
      if (!window["rvtsPopupAlreadyShown"])
        window["rvtsPopupAlreadyShown"] = false;
  
      if (!window["rvtsSmartWidgetCssLinks"])
        window["rvtsSmartWidgetCssLinks"] = [];
  
      function saveSwSource(popupId) {
        swSetCookie("revotas_source", "other", 7, hname);
        swSetCookie("revotas_medium", "sw", 7, hname);
        swSetCookie("revotas_campaign", popupId, 7, hname);
      }
  
      function getScrollPercent() {
        var h = document.documentElement,
          b = document.body,
          st = "scrollTop",
          sh = "scrollHeight";
        return ((h[st] || b[st]) / ((h[sh] || b[sh]) - h.clientHeight)) * 100;
      }
  
      var flexDirection = {
        left: "flex-start",
        right: "flex-end",
        top: "flex-start",
        bottom: "flex-end",
        center: "center",
      };
  
      Array.from(document.body.getElementsByTagName("*")).forEach(function (
        element
      ) {
        if (getComputedStyle(element).zIndex >= maxInt) {
          element.style.setProperty("z-index", maxInt - 1, "important");
        }
      });
  
      function encodeParams(param) {
        if (param.type === "condition") {
          param.params = param.params.map(function (e) {
            return encodeURIComponent(e);
          });
          return param.params;
        } else if (param.type === "group") {
          for (var i = 0; i < param.elements.length; i++) {
            encodeParams(param.elements[i]);
          }
        } else {
          return param;
        }
      }
  
      function decodeParams(param) {
        if (param.type === "condition") {
          param.params = param.params.map(function (e) {
            return decodeURIComponent(e);
          });
          return param.params;
        } else if (param.type === "group") {
          for (var i = 0; i < param.elements.length; i++) {
            decodeParams(param.elements[i]);
          }
        } else {
          return param;
        }
      }
  
      function executeGroup(group, pagesObj, popupId, widgetConfig) {
        var promiseList = [];
  
        decodeParams(group);
  
        function execute(param) {
          if (param.type === "condition") {
            return param.promise;
          } else if (param.type === "group") {
            if (param.elements.length === 1) {
              return execute(param.elements[0]);
            } else {
              if (param.elements.length === 0) return true;
              else
                return param.elements.reduce(function (acc, value) {
                  if (param.operator === "and")
                    return execute(acc) && execute(value);
                  else if (param.operator === "or")
                    return execute(acc) || execute(value);
                });
            }
          } else {
            return param;
          }
        }
  
        (function resolve(param, pagesObj, popupId) {
          if (param.type === "condition") {
            param.promise = __smartWidgetConditionFunctions__[param.f](
              ...param.params,
              pagesObj,
              popupId,
              widgetConfig
            );
            promiseList.push({ obj: param, promise: param.promise });
          } else if (group.type === "group") {
            param.elements.forEach(function (element) {
              resolve(element, pagesObj, popupId);
            });
          }
        })(group, pagesObj, popupId);
        return Promise.all(
          promiseList.map(function (element) {
            return element.promise;
          })
        ).then(function (resp) {
          resp.forEach(function (result, index) {
            promiseList[index].obj.promise = result;
          });
          return execute(group);
        });
      }
  
      function parseDuration(duration) {
        if (duration.substr(-2, 2) === "ms") return parseInt(duration);
        else if (duration.substr(-1, 1) === "s") return parseInt(duration) * 1000;
      }
  
      function closeButton(
        outerSize,
        innerSize,
        outerColor,
        innerColor,
        top,
        right
      ) {
        var button = document.createElement("div");
        button.style.width = outerSize ? outerSize + "px" : "15px";
        button.style.height = outerSize ? outerSize + "px" : "15px";
        button.style.fontSize = innerSize ? innerSize + "px" : "9px";
        //button.style.verticalAlign = 'middle';
        //button.style.textAlign = 'center';
        //button.style.lineHeight = '15px';
        button.style.display = "flex";
        button.style.alignItems = "center";
        button.style.justifyContent = "center";
        button.style.color = innerColor ? innerColor : "white";
        button.style.setProperty("position", "absolute", "important");
        button.style.fontFamily = "sans-serif";
        button.style.top = top ? top + "px" : "5px";
        button.style.right = right ? right + "px" : "5px";
        button.innerHTML = "X";
        button.style.cursor = "pointer";
        button.style.border = "1px solid white";
        button.style.borderRadius = "50%";
        button.style.backgroundColor = outerColor ? outerColor : "black";
        button.classList.add("smart-widget-close-button");
        return button;
      }
  
      function bigCircle(bigCircleBackgroundColor) {
        var button = document.createElement("div");
        button.style.width = "583.69px";
        button.style.height = "514.69px";
        button.style.display = "flex";
        button.style.position = "absolute";
        button.style.backgroundColor = bigCircleBackgroundColor
          ? bigCircleBackgroundColor
          : "linear - gradient(270deg, #FFFFFF 0 %, #6060D7 100 %)";
        button.style.opacity = "0.1";
        button.style.zIndex = "1";
        button.style.borderRadius = "50%";
        button.style.left = "20px";
        button.style.rotate = "180deg";
        button.style.maxWidth = "480px";
        button.classList.add("bigCircle");
        return button;
      }
  
      function minimizeButton() {
        var button = document.createElement("div");
        button.style.width = "15px";
        button.style.height = "15px";
        button.style.fontSize = "9px";
        button.style.verticalAlign = "middle";
        button.style.textAlign = "center";
        button.style.lineHeight = "15px";
        button.style.color = "white";
        button.style.setProperty("position", "absolute", "important");
        button.style.fontFamily = "sans-serif";
        button.style.top = "5px";
        button.style.right = "25px";
        button.innerHTML = "-";
        button.style.cursor = "pointer";
        button.style.border = "1px solid white";
        button.style.borderRadius = "50%";
        button.style.backgroundColor = "black";
        button.classList.add("smart-widget-minimize-button");
        return button;
      }
  
      function arrowButton() {
        var button = document.createElement("div");
        button.style.width = "20px";
        button.style.height = "30px";
        button.style.fontSize = "20px";
        button.style.verticalAlign = "middle";
        button.style.textAlign = "center";
        button.style.lineHeight = "26px";
        button.style.color = "white";
        button.style.fontFamily = "sans-serif";
        button.style.setProperty("position", "absolute", "important");
        button.style.left = "-20px";
        button.style.top = "15px";
        button.innerHTML =
          '<span style="color: white;animation: SWdrawerArrow1 2s infinite;">&lsaquo;</span><span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&lsaquo;</span>';
        button.style.cursor = "pointer";
        button.style.backgroundColor = "black";
        button.style.borderTopLeftRadius = "20px";
        button.style.borderBottomLeftRadius = "20px";
        button.style.borderTopRightRadius = "0";
        button.style.borderBottomRightRadius = "0";
        button.classList.add("smart-widget-toggle-button");
        return {
          button: button,
          setPosition: function (position) {
            if (position === "top") {
              button.style.lineHeight = "20px";
              button.style.width = "30px";
              button.style.height = "20px";
              button.style.left = "unset";
              button.style.right = "unset";
              button.style.bottom = "unset";
              button.style.top = "-20px";
              button.innerHTML = "&#8657;";
              button.style.borderTopLeftRadius = "20px";
              button.style.borderBottomLeftRadius = "0";
              button.style.borderTopRightRadius = "20px";
              button.style.borderBottomRightRadius = "0";
            } else if (position === "bottom") {
              button.style.lineHeight = "20px";
              button.style.width = "30px";
              button.style.height = "20px";
              button.style.left = "unset";
              button.style.right = "unset";
              button.style.top = "unset";
              button.style.bottom = "-20px";
              button.innerHTML = "&#8659;";
              button.style.borderTopLeftRadius = "0";
              button.style.borderBottomLeftRadius = "20px";
              button.style.borderTopRightRadius = "0";
              button.style.borderBottomRightRadius = "20px";
            } else if (position === "left") {
              button.style.lineHeight = "30px";
              button.style.width = "20px";
              button.style.height = "30px";
              button.style.borderTopLeftRadius = "20px";
              button.style.borderBottomLeftRadius = "20px";
              button.style.borderTopRightRadius = "0";
              button.style.borderBottomRightRadius = "0";
              button.style.bottom = "unset";
              button.style.right = "unset";
              button.style.top = "15px";
              button.style.left = "-20px";
              button.innerHTML =
                '<span style="color: white;animation: SWdrawerArrow1 2s infinite;">&lsaquo;</span><span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&lsaquo;</span>';
            } else if (position === "right") {
              button.style.lineHeight = "30px";
              button.style.width = "20px";
              button.style.height = "30px";
              button.style.borderTopLeftRadius = "0";
              button.style.borderBottomLeftRadius = "0";
              button.style.borderTopRightRadius = "20px";
              button.style.borderBottomRightRadius = "20px";
              button.style.left = "unset";
              button.style.bottom = "unset";
              button.style.top = "15px";
              button.style.right = "-20px";
              button.innerHTML =
                '<span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&rsaquo;</span><span style="color: white;animation: SWdrawerArrow1 2s infinite;">&rsaquo;</span>';
            }
          },
          setArrow: function (position) {
            if (position === "top") {
              button.innerHTML = "&#8657;";
            } else if (position === "bottom") {
              button.innerHTML = "&#8659;";
            } else if (position === "left") {
              button.innerHTML =
                '<span style="color: white;animation: SWdrawerArrow1 2s infinite;">&lsaquo;</span><span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&lsaquo;</span>';
            } else if (position === "right") {
              button.innerHTML =
                '<span style="color: #d0d0d0;animation: SWdrawerArrow2 2s infinite;">&rsaquo;</span><span style="color: white;animation: SWdrawerArrow1 2s infinite;">&rsaquo;</span>';
            }
          },
        };
      }
  
      function stickyPopup(params, widgetId, popupName) {
        var subscriptionCallbacks = [];
        var scriptRun = false;
        var scriptTags = [];
  
        var init;
  
        var tempTimeout = null;
        var close = function () {
          if (tempTimeout) return;
          if (!status.open) throw new Error("Popup is already hidden");
          popup.style.transition = "top " + closeDuration + " ease 0s";
          emptyDiv.style.height = "0";
          popup.style.top = "-" + height;
          fixedElements.forEach(function (element) {
            element.style.transition = "top " + closeDuration + " ease 0s";
            element.style.top = "0";
          });
          tempTimeout = setTimeout(function () {
            emptyDiv.remove();
            popup.remove();
            scriptTags.forEach(function (tag) {
              tag.remove();
            });
            status.open = false;
            if (subscriptionCallbacks.length > 0) {
              subscriptionCallbacks.forEach((c) => {
                c.call(selfObject, false);
              });
            }
            tempTimeout = null;
          }, parseDuration(closeDuration));
        };
  
        var status = {
          open: false,
        };
  
        if (params.cssLinks) {
          params.cssLinks.split(",").forEach(function (element) {
            if (!rvtsSmartWidgetCssLinks.includes(element)) {
              var newLink = document.createElement("link");
              newLink.rel = "stylesheet";
              newLink.type = "text/css";
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
        var colorOne = params.colorOne;
        var colorTwo = params.colorTwo;
        var stickyColorRotation = params.stickyColorRotation;
        var borderThickness = params.borderThickness;
        var stickyBorderColor = params.stickyBorderColor;
        var stickyBorderRadius = params.stickyBorderRadius;
        var shadowHorizontal = params.shadowHorizontal;
        var shadowVertical = params.shadowVertical;
        var shadowBlur = params.shadowBlur;
        var shadowColor = params.shadowColor;
        var stickyLink = params.stickyLink;
        var stickyImage = params.stickyImage;
        var stickyFontFamily = params.stickyFontFamily;
        var horizontalAnimation = params.horizontalAnimation;
        var verticalAnimation = params.verticalAnimation;
        var stickImage = params.stickyImage;
        var html = params.html;
        var content = params.content;
        var iframeLink = params.iframeLink;
  
        var observer = null;
  
        var emptyDiv = document.createElement("div");
        emptyDiv.style.height = "0";
  
        var popup = document.createElement("div");
        popup.classList.add("smart-widget-container-div");
        popup.style.backgroundColor = backgroundColor;
  
        if (backgroundColor) {
          popup.style.backgroundColor = backgroundColor;
        }
  
        /*Sticky Gradient*/
        if (colorOne || colorTwo || stickyColorRotation) {
          popup.style.background = `linear-gradient(${stickyColorRotation}deg, ${colorOne}, ${colorTwo})`;
        }
  
        /*Sticky Border*/
        popup.style.border = `${borderThickness}px solid ${stickyBorderColor}`;
  
        /*Sticky Box Shadow*/
        popup.style.borderRadius = `${stickyBorderRadius}px`;
  
        /*Sticky Box Shadow*/
        popup.style.boxShadow = `${shadowHorizontal}px ${shadowVertical}px  ${shadowBlur}px ${shadowColor}`;
  
        /*Sticky Link*/
        if (
          stickyLink !== "" &&
          stickyLink !== null &&
          stickyLink !== undefined
        ) {
          popup.style.cursor = "pointer";
          popup.setAttribute(
            "onclick",
            `window.open("${decodeURIComponent(stickyLink)}");`
          );
        }
  
        popup.style.setProperty("position", "fixed", "important");
        popup.style.width = "100vw";
        popup.style.top = "-" + height;
        popup.style.left = "0";
        popup.style.height = height;
        popup.style.setProperty("z-index", maxInt - 1, "important");
        popup.style.display = "flex";
        popup.style.alignItems = flexDirection[vAlign];
        popup.style.justifyContent = flexDirection[hAlign];
  
        if (html) {
          popup.innerHTML = html;
        } else if (content) {
          popup.innerHTML = content;
        } else if (iframeLink) {
          var iframe = document.createElement("iframe");
          params.iframeClassName.split(" ").forEach(function (element) {
            if (element) iframe.classList.add(element);
          });
          iframe.setAttribute("src", iframeLink);
          if (width.slice(-2) !== "px") width += "px";
          if (height.slice(-2) !== "px") height += "px";
          iframe.style.setProperty(
            "width",
            width === "auto" ? "100%" : width,
            "important"
          );
          iframe.style.setProperty(
            "height",
            height === "auto" ? "100%" : height,
            "important"
          );
          iframe.setAttribute("scrolling", "no");
          iframe.setAttribute("frameborder", "0");
          popup.style.width = "auto";
          popup.style.height = "auto";
          width = "auto";
          height = "auto";
          popup.appendChild(iframe);
        }
  
        /*Sticky Font Family*/
        if (stickyFontFamily !== "" || stickyFontFamily !== null) {
          popup.style.setProperty(
            "font-family",
            decodeURIComponent(stickyFontFamily) + ", " + "sans-serif",
            "important"
          );
        }
  
        /*StickyImage*/
        if (
          stickyImage !== "" &&
          stickyImage !== null &&
          stickyImage !== undefined
        ) {
          var stickyImageElem = document.createElement("img");
          stickyImageElem.src = decodeURIComponent(stickyImage);
          popup.style.overflow = "hidden";
          popup.appendChild(stickyImageElem);
        }
  
        /*Horizontal Animation*/
        if (horizontalAnimation == 1) {
          popup.style.overflow = "hidden";
          var stickyParagraph = document.createElement("p");
          stickyParagraph.style = `
                  position: absolute;
                  right: 0;
                  margin: 0;
              `;
          stickyParagraph.innerHTML = popup.innerHTML;
          popup.innerHTML = "";
          popup.appendChild(stickyParagraph);
  
          const myInterval = setInterval(stickyDomControl, 1000);
  
          function stickyDomControl() {
            var calcOfTextLong =
              (parseInt(window.getComputedStyle(popup).width) /
                parseInt(window.getComputedStyle(stickyParagraph).width)) *
              100;
  
            stickyParagraph.animate(
              [
                { transform: "translateX(100%)" },
                { transform: `translateX(-${calcOfTextLong}%)` },
              ],
              {
                duration: 12000,
                iterations: Infinity,
              }
            );
  
            if (popup) {
              stickyDomControlFinish();
            }
          }
  
          function stickyDomControlFinish() {
            clearInterval(myInterval);
          }
        }
  
        if (horizontalAnimation == 0) {
          var existStickyParagraph = document.querySelector(
            ".smart-widget-container-div > p"
          );
  
          if (existStickyParagraph) {
            popup.innerText = existStickyParagraph.innerText;
            popup.removeChild(existStickyParagraph);
          }
        }
  
        /*Vertical Animation*/
        if (verticalAnimation == 1) {
          stickyContainer.style.overflow = "hidden";
          var stickyParagraph = document.createElement("p");
          stickyParagraph.style = `
              position: absolute;
              height: max-content;
              left: auto;
              right: auto;
              margin: 0;
              `;
          stickyParagraph.innerText = popup.innerText;
          popup.innerText = "";
          popup.appendChild(stickyParagraph);
  
          const myInterval = setInterval(stickyDomControl, 1000);
  
          function stickyDomControl() {
            var calcOfTextLong =
              (parseInt(window.getComputedStyle(popup).height) /
                parseInt(window.getComputedStyle(stickyParagraph).height)) *
              100;
  
            stickyParagraph.animate(
              [
                { transform: `translateY(-${calcOfTextLong}%)` },
                { transform: `translateY(${calcOfTextLong}%)` },
              ],
              {
                duration: 12000,
                iterations: Infinity,
              }
            );
  
            if (popup) {
              stickyDomControlFinish();
            }
          }
  
          function stickyDomControlFinish() {
            clearInterval(myInterval);
          }
        }
  
        if (verticalAnimation == 0) {
          var existStickyParagraph = document.querySelector(
            ".smart-widget-container-div > p"
          );
  
          if (existStickyParagraph) {
            popup.innerText = existStickyParagraph.innerText;
            popup.removeChild(existStickyParagraph);
          }
        }
  
        if (height === "auto") {
          var tempPopup = popup.cloneNode(true);
          tempPopup.style.visibility = "hidden";
          document.body.insertBefore(tempPopup, document.body.firstElementChild);
          init = new Promise(function (resolve, reject) {
            setTimeout(function () {
              height = tempPopup.getBoundingClientRect().height + "px";
              popup.style.top = "-" + height;
              tempPopup.remove();
              resolve();
            }, 500);
          });
        } else {
          init = new Promise(function (resolve, reject) {
            resolve();
          });
        }
  
        var fixedElements;
  
        var selfObject = {
          subscribe: function (subCallback) {
            subscriptionCallbacks.push(subCallback);
          },
          show: function (isPreview, custId, popupId, formId) {
            var thisPopup = this;
            init.then(function () {
              if (status.open && !isPreview)
                throw new Error("Popup is already shown");
              popup.style.transition = "top " + showDuration + " ease 0s";
              fixedElements = [];
              Array.from(
                document.querySelectorAll("*:not(.smart-widget-container-div)")
              ).forEach(function (element) {
                if (
                  getComputedStyle(element).position === "fixed" &&
                  (getComputedStyle(element).top.substr(0, 1) === "0" ||
                    (typeof rvtsStickyPopupList !== "undefined" &&
                      Object.values(rvtsStickyPopupList).length > 0))
                ) {
                  if (
                    !isNaN(parseInt(getComputedStyle(element).top)) &&
                    getComputedStyle(element).top.substr(-2, 2) == "px"
                  )
                    element.swOldTop = parseInt(getComputedStyle(element).top);
                  fixedElements.push(element);
                }
              });
              if (params.fixedElements) {
                Array.from(
                  document.querySelectorAll(params.fixedElements)
                ).forEach(function (element) {
                  if (
                    !isNaN(parseInt(getComputedStyle(element).top)) &&
                    getComputedStyle(element).top.substr(-2, 2) == "px"
                  )
                    element.swOldTop = parseInt(getComputedStyle(element).top);
                  fixedElements.push(element);
                });
              }
              if (params.fixedElementsUnaffected) {
                Array.from(
                  document.querySelectorAll(params.fixedElementsUnaffected)
                ).forEach(function (element) {
                  if (fixedElements.includes(element)) {
                    fixedElements.splice(fixedElements.indexOf(element), 1);
                  }
                });
              }
              document.body.insertBefore(popup, document.body.firstElementChild);
              document.body.insertBefore(emptyDiv, popup);
              if (!scriptRun) {
                Array.from(popup.querySelectorAll("script")).forEach(function (
                  scriptTag
                ) {
                  window.eval(scriptTag.innerHTML);
                  scriptRun = true;
                });
              }
              setTimeout(async function () {
                emptyDiv.style.transition = "height " + showDuration + " ease 0s";
                popup.style.top = 0;
                emptyDiv.style.height = height;
                if (typeof rvtsStickyPopupList === "undefined") {
                  window.rvtsStickyPopupList = {};
                }
                Object.values(rvtsStickyPopupList).forEach((e) => {
                  e.observer.disconnect();
                });
                if (
                  popupId &&
                  rvtsStickyPopupList[popupId] &&
                  rvtsStickyPopupList[popupId].observer
                ) {
                  rvtsStickyPopupList[popupId].observer.disconnect();
                }
                var totalHeight = 0;
                var oldHeight = 0;
                if (Object.values(rvtsStickyPopupList).length > 0) {
                  oldHeight = Object.values(rvtsStickyPopupList)
                    .map((e) => parseInt(e.height))
                    .reduce((a, b) => a + b);
                  totalHeight = parseInt(height) + oldHeight;
                } else {
                  totalHeight = parseInt(height);
                }
                popup.style.top = oldHeight + "px";
                observer = new MutationObserver(function (
                  mutationRecord,
                  observer
                ) {
                  var element = mutationRecord[0].target;
                  if (
                    getComputedStyle(element).position == "fixed" ||
                    getComputedStyle(element).position == "sticky" ||
                    getComputedStyle(element).position == "absolute"
                  ) {
                    element.style.transition = "top " + showDuration + " ease 0s";
                    element.style.setProperty(
                      "top",
                      totalHeight > 0
                        ? parseInt(totalHeight) + "px"
                        : (element.swOldTop ? element.swOldTop : 0) +
                            parseInt(height) +
                            "px",
                      "important"
                    );
                  } else {
                    element.style.transition = "";
                    element.style.top = "";
                  }
                });
                fixedElements.forEach(function (element) {
                  if (
                    getComputedStyle(element).position == "fixed" ||
                    getComputedStyle(element).position == "sticky" ||
                    getComputedStyle(element).position == "absolute"
                  ) {
                    element.style.transition = "top " + showDuration + " ease 0s";
                    element.style.setProperty(
                      "top",
                      totalHeight > 0
                        ? parseInt(totalHeight) + "px"
                        : (element.swOldTop ? element.swOldTop : 0) +
                            parseInt(height) +
                            "px",
                      "important"
                    );
                  }
                  observer.observe(element, { attributes: true });
                });
                if (popupId) {
                  rvtsStickyPopupList[popupId] = {
                    observer: observer,
                    height: height,
                  };
                }
                for (element of Array.from(
                  popup.getElementsByTagName("script")
                )) {
                  var scriptTag = await rvtsAddScript(element.src);
                  if (scriptTag) scriptTags.push(scriptTag);
                }
                status.open = true;
                window["rvtsPopupAlreadyShown"] = true;
                if (params.autoCloseDelay) {
                  setTimeout(function () {
                    if (status.open) thisPopup.close();
                  }, parseDuration(showDuration) +
                    parseDuration(params.autoCloseDelay));
                }
                if (subscriptionCallbacks.length > 0) {
                  subscriptionCallbacks.forEach((c) => {
                    c.call(selfObject, true);
                  });
                }
                if (!isPreview) {
                  saveLastPopupShow(popupId);
                  var fetchParams =
                    "cust_id=" +
                    custId +
                    "&popup_id=" +
                    popupId +
                    "&form_id=" +
                    formId +
                    "&user_agent=" +
                    navigator.userAgent +
                    "&activity_type=0" +
                    "&session_id=" +
                    rvtsSessionId;
                  if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
                  if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                  if (/Mobi|Android/i.test(navigator.userAgent)) {
                    fetchParams += "&device=" + "1"; //mobile
                  } else {
                    fetchParams += "&device=" + "2"; //desktop
                  }
                  fetchParams +=
                    "&url=" +
                    window.location.href.split("&").join(encodeURIComponent("&"));
                  fetch(
                    "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                      fetchParams
                  );
                  rvtsPushGaEvent(0, popupName);
                  document
                    .querySelectorAll("#push-smart-widget-activity")
                    .forEach(function (smartWidgetCallToActionButton) {
                      if (smartWidgetCallToActionButton) {
                        var activityType =
                          smartWidgetCallToActionButton.getAttribute(
                            "activity_type"
                          );
                        if (activityType == "click") activityType = "1";
                        else if (activityType == "submit") activityType = "2";
                        smartWidgetCallToActionButton.addEventListener(
                          "click",
                          function () {
                            var fetchParams = "";
                            fetchParams += "cust_id=" + custId;
                            fetchParams += "&popup_id=" + popupId;
                            fetchParams += "&form_id=" + formId;
                            fetchParams += "&user_agent=" + navigator.userAgent;
                            fetchParams += "&activity_type=" + activityType;
                            fetchParams += "&session_id=" + rvtsSessionId;
                            if (rvtsUserId)
                              fetchParams += "&user_id=" + rvtsUserId;
                            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                            if (/Mobi|Android/i.test(navigator.userAgent)) {
                              fetchParams += "&device=" + "1"; //mobile
                            } else {
                              fetchParams += "&device=" + "2"; //desktop
                            }
                            fetchParams +=
                              "&url=" +
                              window.location.href
                                .split("&")
                                .join(encodeURIComponent("&"));
                            fetch(
                              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                                fetchParams
                            );
                            rvtsPushGaEvent(activityType, popupName);
                            if (activityType == "1") saveSwSource(popupId);
                          }
                        );
                      }
                    });
                }
              }, 250);
            });
          },
          close: close,
          isOpen: function () {
            return status.open;
          },
          getPopup: function () {
            return init.then(function () {
              return popup;
            });
          },
          stopObserver: function () {
            if (observer) {
              observer.disconnect();
              observer = null;
            }
          },
          emptyDiv: emptyDiv,
        };
        return selfObject;
      }
  
      var recoQueryList = [
        "rvts_top_seller",
        "rvts_price_drop",
        "rvts_new_product",
        "rvts_back_in_stock",
        "rvts_buy_also",
        "rvts_similar",
        "rvts_you_might",
        "rvts_view_also",
        "rvts_recently",
        "rvts_trending",
        "rvts_bought_together",
      ];
  
      function slidingPopup(
        params,
        widgetId,
        customCloseButton,
        popupName,
        formId
      ) {
        var isReco = false;
        var subscriptionCallbacks = [];
        var closeTimeout = null;
        var closeCallback = null;
  
        var scriptRun = false;
        var scriptTags = [];
  
        var shadow = null;
  
        var init;
  
        var tempTimeout = null;
        var close = function () {
          if (tempTimeout) return;
          if (!status.open) throw new Error("Popup is already hidden");
          popup.style.transition = ps[0] + " " + closeDuration + " ease 0s";
          var s = styleToHide.split("|");
          popup.style[s[0]] = s[1];
          tempTimeout = setTimeout(function () {
            if (overlayColor) {
              shadow.remove();
              overlay.remove();
              document.body.style.overflow = "";
            } else {
              shadow.remove();
            }
            scriptTags.forEach(function (tag) {
              tag.remove();
            });
            status.open = false;
            if (closeCallback) closeCallback();
            if (closeTimeout) {
              clearTimeout(closeTimeout);
              closeTimeout = null;
            }
            if (subscriptionCallbacks.length > 0) {
              subscriptionCallbacks.forEach((c) => {
                c.call(selfObject, false);
              });
            }
            tempTimeout = null;
          }, parseDuration(closeDuration));
        };
  
        var status = {
          open: false,
        };
  
        if (params.cssLinks) {
          params.cssLinks.split(",").forEach(function (element) {
            if (!rvtsSmartWidgetCssLinks.includes(element)) {
              var newLink = document.createElement("link");
              newLink.rel = "stylesheet";
              newLink.type = "text/css";
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
        var startPosition = params.startPosition; // 'top left' || 'right bottom' etc.
        var vAlign = params.vAlign;
        var hAlign = params.hAlign;
        var html = params.html;
        var thankYouHtml = params.thankYouHtml;
        var iframeLink = params.iframeLink;
        var endPosition = params.endPosition;
        var overlayClick = params.overlayClick;
        var overlayLock = params.overlayLock;
  
        var overlay;
  
        if (overlayColor) {
          overlay = document.createElement("div");
          overlay.style.setProperty("position", "fixed", "important");
          overlay.style.top = "0";
          overlay.style.left = "0";
          overlay.style.backgroundColor = overlayColor;
          overlay.style.setProperty("z-index", maxInt, "important");
          overlay.style.height = "100vh";
          overlay.style.width = "100vw";
        }
  
        var ps = startPosition.split(" ");
        var popup = document.createElement("div");
        popup.classList.add("smart-widget-container-div");
        var button = customCloseButton
          ? customCloseButton
          : closeButton(
              params.closeButtonOuterSize,
              params.closeButtonInnerSize,
              params.closeButtonOuterColor,
              params.closeButtonInnerColor,
              params.closeButtonMarginTop,
              params.closeButtonMarginRight
            );
        button.addEventListener("click", close);
  
        if (params.borderSize)
          popup.style.border = params.borderSize + "px solid";
        if (params.borderColor) popup.style.borderColor = params.borderColor;
        if (params.borderRadius)
          popup.style.borderRadius = params.borderRadius + "px";
        popup.style.backgroundColor = backgroundColor;
        popup.style.overflow = "hidden";
        popup.style.width = width;
        popup.style.height = height;
        popup.style.setProperty("position", "fixed", "important");
        popup.style.display = "flex";
        popup.style.alignItems = flexDirection[vAlign];
        popup.style.justifyContent = flexDirection[hAlign];
  
        var iframe = null;
        var iframeResolver = null;
        var iframeLoaded = null;
        if (html) {
          popup.innerHTML = html;
          recoQueryList.forEach((query) => {
            if (popup.querySelector("." + query)) isReco = true;
          });
          if (thankYouHtml) {
            var f = popup.querySelector("form[name=Subscribe]");
            var formInput = popup.querySelector("input[name=my_form_id]");
            if (f && formInput) {
              formInput.value = formId;
              f.submit = function () {
                var postParam = "";
                for (var el of f.elements) {
                  if (el.tagName.toLowerCase() === "input") {
                    postParam += "&" + el.name + "=" + el.value;
                  }
                }
                postParam = postParam.substring(1);
                fetch("https://revoform.revotas.com/frm/sv/FormProcessor", {
                  credentials: "include",
                  headers: {
                    "content-type": "application/x-www-form-urlencoded",
                  },
                  body: postParam,
                  method: "POST",
                  mode: "no-cors",
                }).then(() => {
                  var closeButton = popup.querySelector(
                    ".smart-widget-close-button"
                  );
                  closeButton.remove();
                  popup.innerHTML = thankYouHtml;
                  popup.appendChild(closeButton);
                });
              };
            }
          }
        } else if (iframeLink) {
          iframeLoaded = new Promise((resolve, reject) => {
            iframeResolver = resolve;
          });
          iframe = document.createElement("iframe");
          iframe.onload = function () {
            iframeResolver();
          };
          params.iframeClassName.split(" ").forEach(function (element) {
            if (element) iframe.classList.add(element);
          });
          iframe.setAttribute("src", iframeLink);
          if (width.slice(-2) !== "px") width += "px";
          if (height.slice(-2) !== "px") height += "px";
          iframe.style.setProperty(
            "width",
            width === "auto" ? "100%" : width,
            "important"
          );
          iframe.style.setProperty(
            "height",
            height === "auto" ? "100%" : height,
            "important"
          );
          iframe.setAttribute("scrolling", "no");
          iframe.setAttribute("frameborder", "0");
          popup.style.width = "auto";
          popup.style.height = "auto";
          width = "auto";
          height = "auto";
          popup.appendChild(iframe);
        }
  
        if (isReco) {
          shadow = popup;
        } else {
          shadow = document.createElement("div");
          shadow.attachShadow({ mode: "open" });
          shadow.shadowRoot.appendChild(popup);
        }
  
        popup.appendChild(button);
  
        var styleToShow = "";
        var styleToHide = "";
  
        if (height === "auto" || width === "auto") {
          var tempPopup = popup.cloneNode(true);
          tempPopup.style.visibility = "hidden";
          document.body.insertBefore(tempPopup, document.body.firstElementChild);
          init = new Promise(function (resolve, reject) {
            setTimeout(function () {
              if (height === "auto")
                height = tempPopup.getBoundingClientRect().height + "px";
              if (width === "auto")
                width = tempPopup.getBoundingClientRect().width + "px";
              tempPopup.remove();
              var value;
              if (ps[0] === "top" || ps[0] === "bottom") {
                value = height;
                if (ps[1] === "center")
                  popup.style.left = "calc(50% - " + parseInt(width) / 2 + "px)";
                else popup.style[ps[1]] = "0";
              } else if (ps[0] === "left" || ps[0] === "right") {
                value = width;
                if (ps[1] === "center")
                  popup.style.top = "calc(50% - " + parseInt(height) / 2 + "px)";
                else popup.style[ps[1]] = "0";
              }
  
              popup.style[ps[0]] = "-" + value;
  
              if (endPosition === "start") styleToShow = ps[0] + "|0px";
              else if (endPosition === "center")
                styleToShow =
                  ps[0] + "|calc(50% - " + parseInt(value) / 2 + "px)";
              else if (endPosition === "end")
                styleToShow = ps[0] + "|calc(100% - " + parseInt(value) + "px)";
              styleToHide = ps[0] + "|-" + value;
              resolve();
            }, 500);
          });
        } else {
          init = new Promise(function (resolve, reject) {
            var value;
            if (ps[0] === "top" || ps[0] === "bottom") {
              value = height;
              if (ps[1] === "center")
                popup.style.left = "calc(50% - " + parseInt(width) / 2 + "px)";
              else popup.style[ps[1]] = "0";
            } else if (ps[0] === "left" || ps[0] === "right") {
              value = width;
              if (ps[1] === "center")
                popup.style.top = "calc(50% - " + parseInt(height) / 2 + "px)";
              else popup.style[ps[1]] = "0";
            }
  
            popup.style[ps[0]] = "-" + value;
  
            if (endPosition === "start") styleToShow = ps[0] + "|0px";
            else if (endPosition === "center")
              styleToShow = ps[0] + "|calc(50% - " + parseInt(value) / 2 + "px)";
            else if (endPosition === "end")
              styleToShow = ps[0] + "|calc(100% - " + parseInt(value) + "px)";
            styleToHide = ps[0] + "|-" + value;
            resolve();
          });
        }
  
        var overlayListenerAdded = false;
  
        var selfObject = {
          subscribe: function (subCallback) {
            subscriptionCallbacks.push(subCallback);
          },
          show: function (isPreview, custId, popupId, formId, callback) {
            if (callback) closeCallback = callback;
            var thisPopup = this;
            init.then(function () {
              if (status.open && !isPreview)
                throw new Error("Popup is already shown");
              popup.style.transition = ps[0] + " " + showDuration + " ease 0s";
              if (overlayColor) {
                if (overlayLock !== "false")
                  document.body.style.overflow = "hidden";
                document.body.insertBefore(
                  overlay,
                  document.body.firstElementChild
                );
                overlay.appendChild(shadow);
                if (!scriptRun) {
                  Array.from(popup.querySelectorAll("script")).forEach(function (
                    scriptTag
                  ) {
                    window.eval(scriptTag.innerHTML);
                    scriptRun = true;
                  });
                }
                if (overlayClick === "close") {
                  if (!overlayListenerAdded) {
                    overlay.addEventListener("click", function (e) {
                      if (e.target === overlay) thisPopup.close();
                    });
                    overlayListenerAdded = true;
                  }
                }
              } else {
                popup.style.setProperty("z-index", maxInt, "important");
                document.body.insertBefore(
                  shadow,
                  document.body.firstElementChild
                );
                if (!scriptRun) {
                  Array.from(popup.querySelectorAll("script")).forEach(function (
                    scriptTag
                  ) {
                    window.eval(scriptTag.innerHTML);
                    scriptRun = true;
                  });
                }
              }
              setTimeout(async function () {
                var s = styleToShow.split("|");
                popup.style[s[0]] = s[1];
                for (element of Array.from(
                  popup.getElementsByTagName("script")
                )) {
                  var scriptTag = await rvtsAddScript(element.src);
                  if (scriptTag) scriptTags.push(scriptTag);
                }
                status.open = true;
                window["rvtsPopupAlreadyShown"] = true;
                if (params.autoCloseDelay) {
                  closeTimeout = setTimeout(function () {
                    if (status.open) thisPopup.close();
                    closeTimeout = null;
                  }, parseDuration(showDuration) +
                    parseDuration(params.autoCloseDelay));
                }
                if (subscriptionCallbacks.length > 0) {
                  subscriptionCallbacks.forEach((c) => {
                    c.call(selfObject, true);
                  });
                }
                if (!isPreview) {
                  saveLastPopupShow(popupId);
                  var fetchParams =
                    "cust_id=" +
                    custId +
                    "&popup_id=" +
                    popupId +
                    "&form_id=" +
                    formId +
                    "&user_agent=" +
                    navigator.userAgent +
                    "&activity_type=0" +
                    "&session_id=" +
                    rvtsSessionId;
                  if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
                  if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                  if (/Mobi|Android/i.test(navigator.userAgent)) {
                    fetchParams += "&device=" + "1"; //mobile
                  } else {
                    fetchParams += "&device=" + "2"; //desktop
                  }
                  fetchParams +=
                    "&url=" +
                    window.location.href.split("&").join(encodeURIComponent("&"));
                  fetch(
                    "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                      fetchParams
                  );
                  rvtsPushGaEvent(0, popupName);
                  (shadow.shadowRoot ? shadow.shadowRoot : shadow)
                    .querySelectorAll("#push-smart-widget-activity")
                    .forEach(function (smartWidgetCallToActionButton) {
                      if (smartWidgetCallToActionButton) {
                        var activityType =
                          smartWidgetCallToActionButton.getAttribute(
                            "activity_type"
                          );
                        if (activityType == "click") activityType = "1";
                        else if (activityType == "submit") activityType = "2";
                        smartWidgetCallToActionButton.addEventListener(
                          "click",
                          function () {
                            var fetchParams = "";
                            fetchParams += "cust_id=" + custId;
                            fetchParams += "&popup_id=" + popupId;
                            fetchParams += "&form_id=" + formId;
                            fetchParams += "&user_agent=" + navigator.userAgent;
                            fetchParams += "&activity_type=" + activityType;
                            fetchParams += "&session_id=" + rvtsSessionId;
                            if (rvtsUserId)
                              fetchParams += "&user_id=" + rvtsUserId;
                            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                            fetchParams += "&url=" + window.location.href;
                            if (/Mobi|Android/i.test(navigator.userAgent)) {
                              fetchParams += "&device=" + "1"; //mobile
                            } else {
                              fetchParams += "&device=" + "2"; //desktop
                            }
                            fetch(
                              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                                fetchParams
                            );
                            rvtsPushGaEvent(activityType, popupName);
                            if (activityType == "1") saveSwSource(popupId);
                          }
                        );
                      }
                    });
                  (shadow.shadowRoot ? shadow.shadowRoot : shadow)
                    .querySelectorAll(
                      "*[activity_type=submit]#push-smart-widget-activity"
                    )
                    .forEach((button) => {
                      button.addEventListener("click", () => {
                        localStorage.setItem("subscribed_" + popupId, 1);
                      });
                    });
  
                  var iframeEvalString =
                    "var activityType=''; var origin='" +
                    window.location.origin +
                    "'; var popupName='" +
                    popupName +
                    "'; var popupId='" +
                    popupId +
                    "'; var rvtsUserId='" +
                    rvtsUserId +
                    "'; var rvtsEmail='" +
                    rvtsEmail +
                    "';document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) { if(smartWidgetCallToActionButton) { activityType = smartWidgetCallToActionButton.getAttribute('activity_type'); if(activityType=='click')activityType='1'; else if(activityType=='submit')activityType='2'; smartWidgetCallToActionButton.addEventListener('click', function(){ var fetchParams = ''; fetchParams+= 'cust_id=" +
                    custId +
                    "'; fetchParams+='&popup_id=" +
                    popupId +
                    "';if(/Mobi|Android/i.test(navigator.userAgent)){fetchParams += '&device=' + '1';} else {fetchParams += '&device=' + '2';} fetchParams+='&form_id=" +
                    formId +
                    "';  fetchParams+='&user_agent='+navigator.userAgent; fetchParams+='&activity_type='+activityType; fetchParams+='&session_id=" +
                    rvtsSessionId +
                    "'; if(rvtsUserId)fetchParams += '&user_id=" +
                    rvtsUserId +
                    "'; if(rvtsEmail)fetchParams += '&email=" +
                    rvtsEmail +
                    "';fetchParams+='&url=" +
                    window.location.href
                      .split("&")
                      .join(encodeURIComponent("&")) +
                    "'; fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams); parent.postMessage({swExecJSCode : true, JSCode : encodeURIComponent('rvtsPushGaEvent(\"'+activityType+'\",\"'+popupName+'\");')}, origin);if(activityType=='1'){parent.postMessage({swExecJSCode : true, JSCode : encodeURIComponent('saveSwSource(\"'+popupId+'\");')}, origin);}}); } });document.querySelectorAll('*[activity_type=submit]#push-smart-widget-activity').forEach(button => { button.addEventListener('click', () => { parent.postMessage({ swExecJSCode: true, JSCode: encodeURIComponent('localStorage.setItem(\"subscribed_' + popupId + '\",1);') }, origin); }); });";
                  if (iframe) {
                    var messageObject = {
                      swExecJSCode: true,
                      popupId: popupId,
                      JSCode: encodeURIComponent(iframeEvalString),
                    };
                    iframeLoaded.then(() => {
                      iframe.contentWindow.postMessage(messageObject, iframeLink);
                    });
                  }
                }
              }, 250);
            });
          },
          close: close,
          isOpen: function () {
            return status.open;
          },
          getPopup: function () {
            return init.then(function () {
              return popup;
            });
          },
          getHeight: function () {
            return height;
          },
          getWidth: function () {
            return width;
          },
        };
        return selfObject;
      }
  
      function fadingPopup(
        params,
        widgetId,
        customCloseButton,
        popupName,
        formId,
        noShadow
      ) {
        var isReco = false;
        var subscriptionCallbacks = [];
        var closeTimeout = null;
        var closeCallback = null;
  
        var scriptRun = false;
        var scriptTags = [];
  
        var shadow = null;
  
        var init;
  
        var tempTimeout = null;
        var close = function () {
          if (tempTimeout) return;
          if (!status.open) throw new Error("Popup is already hidden");
          popup.style.transition = "opacity " + closeDuration + " ease 0s";
          popup.style.opacity = "0";
          if (overlayColor) {
            overlay.style.transition = "opacity " + closeDuration + " ease 0s";
            overlay.style.opacity = "0";
          }
          tempTimeout = setTimeout(function () {
            if (overlayColor) {
              shadow.remove();
              overlay.remove();
              document.body.style.overflow = "";
            } else {
              shadow.remove();
            }
            scriptTags.forEach(function (tag) {
              tag.remove();
            });
            status.open = false;
            if (closeCallback) closeCallback();
            if (closeTimeout) {
              clearTimeout(closeTimeout);
              closeTimeout = null;
            }
            if (subscriptionCallbacks.length > 0) {
              subscriptionCallbacks.forEach((c) => {
                c.call(selfObject, false);
              });
            }
            tempTimeout = null;
          }, parseDuration(closeDuration));
        };
  
        var status = {
          open: false,
        };
  
        if (params.cssLinks) {
          params.cssLinks.split(",").forEach(function (element) {
            if (!rvtsSmartWidgetCssLinks.includes(element)) {
              var newLink = document.createElement("link");
              newLink.rel = "stylesheet";
              newLink.type = "text/css";
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
        var position = params.position; // 'top left' || 'right bottom' etc.
        var vAlign = params.vAlign;
        var hAlign = params.hAlign;
        var html = params.html;
        var thankYouHtml = params.thankYouHtml;
        var iframeLink = params.iframeLink;
        var overlayClick = params.overlayClick;
        var overlayLock = params.overlayLock;
  
        var overlay;
  
        if (overlayColor) {
          overlay = document.createElement("div");
          overlay.style.setProperty("position", "fixed", "important");
          overlay.style.top = "0";
          overlay.style.left = "0";
          overlay.style.backgroundColor = overlayColor;
          overlay.style.setProperty("z-index", maxInt, "important");
          overlay.style.height = "100vh";
          overlay.style.width = "100vw";
          overlay.style.opacity = "0";
        }
  
        var popup = document.createElement("div");
        popup.classList.add("smart-widget-container-div");
  
        var button = customCloseButton
          ? customCloseButton
          : closeButton(
              params.closeButtonOuterSize,
              params.closeButtonInnerSize,
              params.closeButtonOuterColor,
              params.closeButtonInnerColor,
              params.closeButtonMarginTop,
              params.closeButtonMarginRight
            );
  
        var ps = position.split(" ");
  
        button.addEventListener("click", close);
  
        if (params.borderSize)
          popup.style.border = params.borderSize + "px solid";
        if (params.borderColor) popup.style.borderColor = params.borderColor;
        if (params.borderRadius)
          popup.style.borderRadius = params.borderRadius + "px";
        popup.style.backgroundColor = backgroundColor;
        popup.style.overflow = "hidden";
        popup.style.width = width;
        popup.style.height = height;
        popup.style.setProperty("position", "fixed", "important");
        popup.style.display = "flex";
        popup.style.alignItems = flexDirection[vAlign];
        popup.style.justifyContent = flexDirection[hAlign];
        popup.style.opacity = "0";
  
        var iframe = null;
        var iframeResolver = null;
        var iframeLoaded = null;
        if (html) {
          popup.innerHTML = html;
          recoQueryList.forEach((query) => {
            if (popup.querySelector("." + query)) isReco = true;
          });
          if (thankYouHtml) {
            var f = popup.querySelector("form[name=Subscribe]");
            var formInput = popup.querySelector("input[name=my_form_id]");
            if (f && formInput) {
              formInput.value = formId;
              f.submit = function () {
                var postParam = "";
                for (var el of f.elements) {
                  if (el.tagName.toLowerCase() === "input") {
                    postParam += "&" + el.name + "=" + el.value;
                  }
                }
                postParam = postParam.substring(1);
                fetch("https://revoform.revotas.com/frm/sv/FormProcessor", {
                  credentials: "include",
                  headers: {
                    "content-type": "application/x-www-form-urlencoded",
                  },
                  body: postParam,
                  method: "POST",
                  mode: "no-cors",
                }).then(() => {
                  var closeButton = popup.querySelector(
                    ".smart-widget-close-button"
                  );
                  closeButton.remove();
                  popup.innerHTML = thankYouHtml;
                  popup.appendChild(closeButton);
                });
              };
            }
          }
        } else if (iframeLink) {
          iframeLoaded = new Promise((resolve, reject) => {
            iframeResolver = resolve;
          });
          iframe = document.createElement("iframe");
          iframe.onload = function () {
            iframeResolver();
          };
          params.iframeClassName.split(" ").forEach(function (element) {
            if (element) iframe.classList.add(element);
          });
          iframe.setAttribute("src", iframeLink);
          if (width.slice(-2) !== "px") width += "px";
          if (height.slice(-2) !== "px") height += "px";
          iframe.style.setProperty(
            "width",
            width === "auto" ? "100%" : width,
            "important"
          );
          iframe.style.setProperty(
            "height",
            height === "auto" ? "100%" : height,
            "important"
          );
          iframe.setAttribute("scrolling", "no");
          iframe.setAttribute("frameborder", "0");
          popup.style.width = "auto";
          popup.style.height = "auto";
          width = "auto";
          height = "auto";
          popup.appendChild(iframe);
        }
  
        if (isReco || noShadow) {
          shadow = popup;
        } else {
          shadow = document.createElement("div");
          shadow.setAttribute("id", "rvtsFadingDiv");
          shadow.attachShadow({ mode: "open" });
          shadow.shadowRoot.appendChild(popup);
        }
  
        popup.appendChild(button);
  
        if (height === "auto" || width === "auto") {
          var tempPopup = popup.cloneNode(true);
          tempPopup.style.visibility = "hidden";
          document.body.insertBefore(tempPopup, document.body.firstElementChild);
          init = new Promise(function (resolve, reject) {
            setTimeout(function () {
              if (height === "auto")
                height = tempPopup.getBoundingClientRect().height + "px";
              if (width === "auto")
                width = tempPopup.getBoundingClientRect().width + "px";
              tempPopup.remove();
              if (ps[0] === "center") {
                popup.style.left = "calc(50% - " + parseInt(width) / 2 + "px)";
                popup.style.top = "calc(50% - " + parseInt(height) / 2 + "px)";
              } else if (ps[0] === "top" || ps[0] === "bottom") {
                if (ps[1] === "center")
                  popup.style.left = "calc(50% - " + parseInt(width) / 2 + "px)";
                else popup.style[ps[1]] = "0";
              } else if (ps[0] === "left" || ps[0] === "right") {
                if (ps[1] === "center")
                  popup.style.top = "calc(50% - " + parseInt(height) / 2 + "px)";
                else popup.style[ps[1]] = "0";
              }
              resolve();
            }, 500);
          });
        } else {
          init = new Promise(function (resolve, reject) {
            if (ps[0] === "center") {
              popup.style.left = "calc(50% - " + parseInt(width) / 2 + "px)";
              popup.style.top = "calc(50% - " + parseInt(height) / 2 + "px)";
            } else if (ps[0] === "top" || ps[0] === "bottom") {
              if (ps[1] === "center")
                popup.style.left = "calc(50% - " + parseInt(width) / 2 + "px)";
              else popup.style[ps[1]] = "0";
            } else if (ps[0] === "left" || ps[0] === "right") {
              if (ps[1] === "center")
                popup.style.top = "calc(50% - " + parseInt(height) / 2 + "px)";
              else popup.style[ps[1]] = "0";
            }
            resolve();
          });
        }
        popup.style[ps[0]] = "0";
  
        var overlayListenerAdded = false;
  
        var selfObject = {
          subscribe: function (subCallback) {
            subscriptionCallbacks.push(subCallback);
          },
          show: function (isPreview, custId, popupId, formId, callback) {
            if (callback) closeCallback = callback;
            var thisPopup = this;
            init.then(function () {
              if (status.open && !isPreview)
                throw new Error("Popup is already shown");
              popup.style.transition = "opacity " + showDuration + " ease 0s";
              if (overlayColor) {
                overlay.style.transition = "opacity " + showDuration + " ease 0s";
                if (overlayLock !== "false")
                  document.body.style.overflow = "hidden";
                document.body.insertBefore(
                  overlay,
                  document.body.firstElementChild
                );
                overlay.appendChild(shadow);
                if (!scriptRun) {
                  Array.from(popup.querySelectorAll("script")).forEach(function (
                    scriptTag
                  ) {
                    window.eval(scriptTag.innerHTML);
                    scriptRun = true;
                  });
                }
                if (overlayClick === "close") {
                  if (!overlayListenerAdded) {
                    overlay.addEventListener("click", function (e) {
                      if (e.target === overlay) thisPopup.close();
                    });
                    overlayListenerAdded = true;
                  }
                }
              } else {
                popup.style.setProperty("z-index", maxInt, "important");
                document.body.insertBefore(
                  shadow,
                  document.body.firstElementChild
                );
                if (!scriptRun) {
                  Array.from(popup.querySelectorAll("script")).forEach(function (
                    scriptTag
                  ) {
                    window.eval(scriptTag.innerHTML);
                    scriptRun = true;
                  });
                }
              }
              setTimeout(async function () {
                if (overlayColor) {
                  overlay.style.opacity = "1";
                }
                popup.style.opacity = "1";
                for (element of Array.from(
                  popup.getElementsByTagName("script")
                )) {
                  var scriptTag = await rvtsAddScript(element.src);
                  if (scriptTag) scriptTags.push(scriptTag);
                }
                status.open = true;
                window["rvtsPopupAlreadyShown"] = true;
                if (params.autoCloseDelay) {
                  closeTimeout = setTimeout(function () {
                    if (status.open) thisPopup.close();
                    closeTimeout = null;
                  }, parseDuration(showDuration) +
                    parseDuration(params.autoCloseDelay));
                }
                if (subscriptionCallbacks.length > 0) {
                  subscriptionCallbacks.forEach((c) => {
                    c.call(selfObject, true);
                  });
                }
                if (!isPreview) {
                  saveLastPopupShow(popupId);
                  var fetchParams =
                    "cust_id=" +
                    custId +
                    "&popup_id=" +
                    popupId +
                    "&form_id=" +
                    formId +
                    "&user_agent=" +
                    navigator.userAgent +
                    "&activity_type=0" +
                    "&session_id=" +
                    rvtsSessionId;
                  if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
                  if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                  if (/Mobi|Android/i.test(navigator.userAgent)) {
                    fetchParams += "&device=" + "1";
                  } else {
                    fetchParams += "&device=" + "2";
                  }
                  fetchParams +=
                    "&url=" +
                    window.location.href.split("&").join(encodeURIComponent("&"));
                  fetch(
                    "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                      fetchParams
                  );
                  rvtsPushGaEvent(0, popupName);
                  (shadow.shadowRoot ? shadow.shadowRoot : shadow)
                    .querySelectorAll("#push-smart-widget-activity")
                    .forEach(function (smartWidgetCallToActionButton) {
                      if (smartWidgetCallToActionButton) {
                        var activityType =
                          smartWidgetCallToActionButton.getAttribute(
                            "activity_type"
                          );
                        if (activityType == "click") activityType = "1";
                        else if (activityType == "submit") activityType = "2";
                        smartWidgetCallToActionButton.addEventListener(
                          "click",
                          function () {
                            var fetchParams = "";
                            fetchParams += "cust_id=" + custId;
                            fetchParams += "&popup_id=" + popupId;
                            fetchParams += "&form_id=" + formId;
                            fetchParams += "&user_agent=" + navigator.userAgent;
                            fetchParams += "&activity_type=" + activityType;
                            fetchParams += "&session_id=" + rvtsSessionId;
                            if (rvtsUserId)
                              fetchParams += "&user_id=" + rvtsUserId;
                            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                            if (/Mobi|Android/i.test(navigator.userAgent)) {
                              fetchParams += "&device=" + "1";
                            } else {
                              fetchParams += "&device=" + "2";
                            }
                            fetchParams +=
                              "&url=" +
                              window.location.href
                                .split("&")
                                .join(encodeURIComponent("&"));
                            fetch(
                              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                                fetchParams
                            );
                            rvtsPushGaEvent(activityType, popupName);
                            if (activityType == "1") saveSwSource(popupId);
                          }
                        );
                      }
                    });
                  (shadow.shadowRoot ? shadow.shadowRoot : shadow)
                    .querySelectorAll(
                      "*[activity_type=submit]#push-smart-widget-activity"
                    )
                    .forEach((button) => {
                      button.addEventListener("click", () => {
                        localStorage.setItem("subscribed_" + popupId, 1);
                      });
                    });
                  var iframeEvalString =
                    "var activityType=''; var origin='" +
                    window.location.origin +
                    "'; var popupName='" +
                    popupName +
                    "'; var popupId='" +
                    popupId +
                    "'; var rvtsUserId='" +
                    rvtsUserId +
                    "'; var rvtsEmail='" +
                    rvtsEmail +
                    "';document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) { if(smartWidgetCallToActionButton) { activityType = smartWidgetCallToActionButton.getAttribute('activity_type'); if(activityType=='click')activityType='1'; else if(activityType=='submit')activityType='2'; smartWidgetCallToActionButton.addEventListener('click', function(){ var fetchParams = ''; fetchParams+= 'cust_id=" +
                    custId +
                    "'; fetchParams+='&popup_id=" +
                    popupId +
                    "';if(/Mobi|Android/i.test(navigator.userAgent)){fetchParams += '&device=' + '1';} else {fetchParams += '&device=' + '2';} fetchParams+='&form_id=" +
                    formId +
                    "';  fetchParams+='&user_agent='+navigator.userAgent; fetchParams+='&activity_type='+activityType; fetchParams+='&session_id=" +
                    rvtsSessionId +
                    "'; if(rvtsUserId)fetchParams += '&user_id=" +
                    rvtsUserId +
                    "'; if(rvtsEmail)fetchParams += '&email=" +
                    rvtsEmail +
                    "';fetchParams+='&url=" +
                    window.location.href
                      .split("&")
                      .join(encodeURIComponent("&")) +
                    "'; fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams); parent.postMessage({swExecJSCode : true, JSCode : encodeURIComponent('rvtsPushGaEvent(\"'+activityType+'\",\"'+popupName+'\");')}, origin);if(activityType=='1'){parent.postMessage({swExecJSCode : true, JSCode : encodeURIComponent('saveSwSource(\"'+popupId+'\");')}, origin);}}); } });document.querySelectorAll('*[activity_type=submit]#push-smart-widget-activity').forEach(button => { button.addEventListener('click', () => { parent.postMessage({ swExecJSCode: true, JSCode: encodeURIComponent('localStorage.setItem(\"subscribed_' + popupId + '\",1);') }, origin); }); });";
                  if (iframe) {
                    var messageObject = {
                      swExecJSCode: true,
                      popupId: popupId,
                      JSCode: encodeURIComponent(iframeEvalString),
                    };
                    iframeLoaded.then(() => {
                      iframe.contentWindow.postMessage(messageObject, iframeLink);
                    });
                  }
                }
              }, 250);
            });
          },
          close: close,
          isOpen: function () {
            return status.open;
          },
          getPopup: function () {
            return init.then(function () {
              return popup;
            });
          },
          getHeight: function () {
            return height;
          },
          getWidth: function () {
            return width;
          },
        };
        return selfObject;
      }
  
      function drawerPopup(params, widgetId, popupName) {
        var isPrev = null;
        var cId = null;
        var pId = null;
        var fId = null;
  
        var subscriptionCallbacks = [];
        var closeTimeout = null;
  
        var newStyleElement = document.createElement("style");
        newStyleElement.innerHTML =
          "@keyframes SWdrawerArrow1{0%{color: white;}50%{color: gray;}100%{color:white;}} @keyframes SWdrawerArrow2{0%{color: #d0d0d0;}50%{color:gray;}100%{color:#d0d0d0;}}";
        document.head.appendChild(newStyleElement);
  
        var scriptRun = false;
        var scriptTags = [];
  
        var init;
  
        var stateObj = (function () {
          var state = 1;
          return {
            toggle: function () {
              return ++state == 3 ? (state = 1) : state;
            },
            get: function () {
              return state;
            },
          };
        })();
  
        var toggleState = stateObj.toggle;
        var getState = stateObj.get;
  
        if (params.drawerStartState === "opened") toggleState();
  
        var tempTimeout = null;
        var close = function () {
          if (tempTimeout) return;
          if (!status.open) throw new Error("Popup is already hidden");
          popup.style.transition = ps[0] + " " + closeDuration + " ease 0s";
          var s = styleToHide.split("|");
          popup.style[s[0]] = s[1];
          tempTimeout = setTimeout(function () {
            if (overlayColor) {
              popup.remove();
              overlay.remove();
              document.body.style.overflow = "";
            } else {
              popup.remove();
            }
            scriptTags.forEach(function (tag) {
              tag.remove();
            });
            status.open = false;
            if (closeTimeout) {
              clearTimeout(closeTimeout);
              closeTimeout = null;
            }
            if (subscriptionCallbacks.length > 0) {
              subscriptionCallbacks.forEach((c) => {
                c.call(selfObject, false);
              });
            }
            tempTimeout = null;
          }, parseDuration(closeDuration));
        };
  
        var status = {
          open: false,
        };
  
        if (params.cssLinks) {
          params.cssLinks.split(",").forEach(function (element) {
            if (!rvtsSmartWidgetCssLinks.includes(element)) {
              var newLink = document.createElement("link");
              newLink.rel = "stylesheet";
              newLink.type = "text/css";
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
        var startPosition = params.startPosition; // 'top left' || 'right bottom' etc.
        var vAlign = params.vAlign;
        var hAlign = params.hAlign;
        var html = params.html;
        var iframeLink = params.iframeLink;
        var overlayClick = params.overlayClick;
        var overlayLock = params.overlayLock;
  
        var overlay;
  
        if (overlayColor) {
          overlay = document.createElement("div");
          overlay.style.setProperty("position", "fixed", "important");
          overlay.style.top = "0";
          overlay.style.left = "0";
          overlay.style.backgroundColor = overlayColor;
          overlay.style.setProperty("z-index", maxInt, "important");
          overlay.style.height = "100vh";
          overlay.style.width = "100vw";
        }
  
        var ps = startPosition.split(" ");
        var orientation;
        var popup = document.createElement("div");
        popup.classList.add("smart-widget-container-div");
        var button = closeButton();
        var minButton = minimizeButton();
        var toggleButton = arrowButton();
        button.addEventListener("click", close);
  
        popup.style.backgroundColor = backgroundColor;
        popup.style.width = width;
        popup.style.height = height;
        popup.style.setProperty("position", "fixed", "important");
        popup.style.display = "flex";
        popup.style.alignItems = flexDirection[vAlign];
        popup.style.justifyContent = flexDirection[hAlign];
        popup.style.border = "1px solid #bbb";
  
        var iframe = null;
        var iframeResolver = null;
        var iframeLoaded = null;
        if (html) {
          popup.innerHTML = html;
        } else if (iframeLink) {
          iframeLoaded = new Promise((resolve, reject) => {
            iframeResolver = resolve;
          });
          iframe = document.createElement("iframe");
          iframe.onload = function () {
            iframeResolver();
          };
          params.iframeClassName.split(" ").forEach(function (element) {
            if (element) iframe.classList.add(element);
          });
          iframe.setAttribute("src", iframeLink);
          if (width.slice(-2) !== "px") width += "px";
          if (height.slice(-2) !== "px") height += "px";
          iframe.style.setProperty(
            "width",
            width === "auto" ? "100%" : width,
            "important"
          );
          iframe.style.setProperty(
            "height",
            height === "auto" ? "100%" : height,
            "important"
          );
          iframe.setAttribute("scrolling", "no");
          iframe.setAttribute("frameborder", "0");
          popup.style.width = "auto";
          popup.style.height = "auto";
          width = "auto";
          height = "auto";
          popup.appendChild(iframe);
        }
        popup.appendChild(button);
        popup.appendChild(minButton);
        popup.appendChild(toggleButton.button);
  
        var styleToShow = "";
        var styleToHide = "";
  
        var value;
  
        if (height === "auto" || width === "auto") {
          var tempPopup = popup.cloneNode(true);
          tempPopup.style.visibility = "hidden";
          document.body.insertBefore(tempPopup, document.body.firstElementChild);
          init = new Promise(function (resolve, reject) {
            setTimeout(function () {
              if (height === "auto")
                height = tempPopup.getBoundingClientRect().height + "px";
              if (width === "auto")
                width = tempPopup.getBoundingClientRect().width + "px";
              tempPopup.remove();
              if (ps[0] === "top" || ps[0] === "bottom") {
                value = height;
                if (ps[1] === "center")
                  popup.style.left = "calc(50% - " + parseInt(width) / 2 + "px)";
                else popup.style[ps[1]] = "0";
              } else if (ps[0] === "left" || ps[0] === "right") {
                value = width;
                if (ps[1] === "center")
                  popup.style.top = "calc(50% - " + parseInt(height) / 2 + "px)";
                else popup.style[ps[1]] = "0";
              }
              value = previewSize;
              popup.style[ps[0]] = "-" + value;
  
              styleToShow = ps[0] + "|0px";
              styleToHide = ps[0] + "|-" + value;
              resolve();
            }, 500);
          });
        } else {
          init = new Promise(function (resolve, reject) {
            if (ps[0] === "top" || ps[0] === "bottom") {
              value = height;
              if (ps[1] === "center")
                popup.style.left = "calc(50% - " + parseInt(width) / 2 + "px)";
              else popup.style[ps[1]] = "0";
            } else if (ps[0] === "left" || ps[0] === "right") {
              value = width;
              if (ps[1] === "center")
                popup.style.top = "calc(50% - " + parseInt(height) / 2 + "px)";
              else popup.style[ps[1]] = "0";
            }
            value = previewSize;
            popup.style[ps[0]] = "-" + value;
  
            styleToShow = ps[0] + "|0px";
            styleToHide = ps[0] + "|-" + value;
            resolve();
          });
        }
  
        var overlayListenerAdded = false;
  
        var show = function (isPreview, custId, popupId, formId) {
          isPrev = isPreview;
          cId = custId;
          pId = popupId;
          fId = formId;
          var thisPopup = this;
          init.then(function () {
            if (status.open && !isPreview)
              throw new Error("Popup is already shown");
            popup.style.transition = ps[0] + " " + showDuration + " ease 0s";
  
            if (getState() === 1) {
              button.style.display = "none";
              minButton.style.display = "none";
              toggleButton.button.style.display = "block";
              popup.style[ps[0]] = "-" + previewSize;
              if (ps[0] === "top" || ps[0] === "bottom") {
                if (ps[0] === "top") toggleButton.setPosition("bottom");
                else if (ps[0] === "bottom") toggleButton.setPosition("top");
                if (iframe)
                  iframe.style.setProperty("height", previewSize, "important");
                else popup.style.height = previewSize;
              } else {
                if (ps[0] === "left") toggleButton.setPosition("right");
                else if (ps[0] === "right") toggleButton.setPosition("left");
                if (iframe)
                  iframe.style.setProperty("width", previewSize, "important");
                else popup.style.width = previewSize;
              }
              styleToHide = ps[0] + "|-" + previewSize;
            } else if (getState() === 2) {
              button.style.display = "flex";
              minButton.style.display = "block";
              toggleButton.button.style.display = "none";
              if (ps[0] === "top" || ps[0] === "bottom") {
                if (ps[0] === "top") toggleButton.setPosition("bottom");
                else if (ps[0] === "bottom") toggleButton.setPosition("top");
                toggleButton.setArrow(ps[0]);
                popup.style[ps[0]] = "-" + height;
                styleToHide = ps[0] + "|-" + height;
                if (iframe)
                  iframe.style.setProperty("height", height, "important");
                else popup.style.height = height;
              } else {
                if (ps[0] === "left") toggleButton.setPosition("right");
                else if (ps[0] === "right") toggleButton.setPosition("left");
                toggleButton.setArrow(ps[0]);
                popup.style[ps[0]] = "-" + width;
                styleToHide = ps[0] + "|-" + width;
                if (iframe) iframe.style.setProperty("width", width, "important");
                else popup.style.width = width;
              }
            }
  
            if (overlayColor) {
              if (overlayLock !== "false")
                document.body.style.overflow = "hidden";
              document.body.insertBefore(
                overlay,
                document.body.firstElementChild
              );
              overlay.appendChild(popup);
              if (!scriptRun) {
                Array.from(popup.querySelectorAll("script")).forEach(function (
                  scriptTag
                ) {
                  window.eval(scriptTag.innerHTML);
                  scriptRun = true;
                });
              }
              if (overlayClick === "close") {
                if (!overlayListenerAdded) {
                  overlay.addEventListener("click", function (e) {
                    if (e.target === overlay) thisPopup.close();
                  });
                  overlayListenerAdded = true;
                }
              }
            } else {
              popup.style.setProperty("z-index", maxInt, "important");
              document.body.insertBefore(popup, document.body.firstElementChild);
              if (!scriptRun) {
                Array.from(popup.querySelectorAll("script")).forEach(function (
                  scriptTag
                ) {
                  window.eval(scriptTag.innerHTML);
                  scriptRun = true;
                });
              }
            }
            setTimeout(async function () {
              var s = styleToShow.split("|");
              popup.style[s[0]] = s[1];
              for (element of Array.from(popup.getElementsByTagName("script"))) {
                var scriptTag = await rvtsAddScript(element.src);
                if (scriptTag) scriptTags.push(scriptTag);
              }
              status.open = true;
              window["rvtsPopupAlreadyShown"] = true;
              if (params.autoCloseDelay) {
                closeTimeout = setTimeout(function () {
                  if (status.open) thisPopup.close();
                  closeTimeout = null;
                }, parseDuration(showDuration) +
                  parseDuration(params.autoCloseDelay));
              }
              if (subscriptionCallbacks.length > 0) {
                subscriptionCallbacks.forEach((c) => {
                  c.call(selfObject, true);
                });
              }
              if (!isPreview) {
                saveLastPopupShow(popupId);
                var fetchParams =
                  "cust_id=" +
                  custId +
                  "&popup_id=" +
                  popupId +
                  "&form_id=" +
                  formId +
                  "&user_agent=" +
                  navigator.userAgent +
                  "&activity_type=0" +
                  "&session_id=" +
                  rvtsSessionId;
                if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
                if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                if (/Mobi|Android/i.test(navigator.userAgent)) {
                  fetchParams += "&device=" + "1";
                } else {
                  fetchParams += "&device=" + "2";
                }
                fetchParams +=
                  "&url=" +
                  window.location.href.split("&").join(encodeURIComponent("&"));
                fetch(
                  "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                    fetchParams
                );
                rvtsPushGaEvent(0, popupName);
                document
                  .querySelectorAll("#push-smart-widget-activity")
                  .forEach(function (smartWidgetCallToActionButton) {
                    if (smartWidgetCallToActionButton) {
                      var activityType =
                        smartWidgetCallToActionButton.getAttribute(
                          "activity_type"
                        );
                      if (activityType == "click") activityType = "1";
                      else if (activityType == "submit") activityType = "2";
                      smartWidgetCallToActionButton.addEventListener(
                        "click",
                        function () {
                          var fetchParams = "";
                          fetchParams += "cust_id=" + custId;
                          fetchParams += "&popup_id=" + popupId;
                          fetchParams += "&form_id=" + formId;
                          fetchParams += "&user_agent=" + navigator.userAgent;
                          fetchParams += "&activity_type=" + activityType;
                          fetchParams += "&session_id=" + rvtsSessionId;
                          if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
                          if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                          if (/Mobi|Android/i.test(navigator.userAgent)) {
                            fetchParams += "&device=" + "1";
                          } else {
                            fetchParams += "&device=" + "2";
                          }
                          fetchParams +=
                            "&url=" +
                            window.location.href
                              .split("&")
                              .join(encodeURIComponent("&"));
                          fetch(
                            "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                              fetchParams
                          );
                          rvtsPushGaEvent(activityType, popupName);
                          if (activityType == "1") saveSwSource(popupId);
                        }
                      );
                    }
                  });
                var iframeEvalString =
                  "var activityType=''; var origin='" +
                  window.location.origin +
                  "'; var popupName='" +
                  popupName +
                  "'; var popupId='" +
                  popupId +
                  "'; var rvtsUserId='" +
                  rvtsUserId +
                  "'; var rvtsEmail='" +
                  rvtsEmail +
                  "';document.querySelectorAll('#push-smart-widget-activity').forEach(function(smartWidgetCallToActionButton) { if(smartWidgetCallToActionButton) { activityType = smartWidgetCallToActionButton.getAttribute('activity_type'); if(activityType=='click')activityType='1'; else if(activityType=='submit')activityType='2'; smartWidgetCallToActionButton.addEventListener('click', function(){ var fetchParams = ''; fetchParams+= 'cust_id=" +
                  custId +
                  "'; fetchParams+='&popup_id=" +
                  popupId +
                  "';if(/Mobi|Android/i.test(navigator.userAgent)){fetchParams += '&device=' + '1';} else {fetchParams += '&device=' + '2';} fetchParams+='&form_id=" +
                  formId +
                  "';  fetchParams+='&user_agent='+navigator.userAgent; fetchParams+='&activity_type='+activityType; fetchParams+='&session_id=" +
                  rvtsSessionId +
                  "'; if(rvtsUserId)fetchParams += '&user_id=" +
                  rvtsUserId +
                  "'; if(rvtsEmail)fetchParams += '&email=" +
                  rvtsEmail +
                  "';fetchParams+='&url=" +
                  window.location.href.split("&").join(encodeURIComponent("&")) +
                  "'; fetch('https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?' + fetchParams); parent.postMessage({swExecJSCode : true, JSCode : encodeURIComponent('rvtsPushGaEvent(\"'+activityType+'\",\"'+popupName+'\");')}, origin);if(activityType=='1'){parent.postMessage({swExecJSCode : true, JSCode : encodeURIComponent('saveSwSource(\"'+popupId+'\");')}, origin);}}); } });document.querySelectorAll('*[activity_type=submit]#push-smart-widget-activity').forEach(button => { button.addEventListener('click', () => { parent.postMessage({ swExecJSCode: true, JSCode: encodeURIComponent('localStorage.setItem(\"subscribed_' + popupId + '\",1);') }, origin); }); });";
                if (iframe) {
                  var messageObject = {
                    swExecJSCode: true,
                    popupId: popupId,
                    JSCode: encodeURIComponent(iframeEvalString),
                  };
                  iframeLoaded.then(() => {
                    iframe.contentWindow.postMessage(messageObject, iframeLink);
                  });
                }
              }
            }, 250);
          });
        };
  
        toggleButton.button.addEventListener("click", function () {
          close();
          toggleState();
          setTimeout(function () {
            show(isPrev, cId, pId, fId);
          }, parseDuration(closeDuration));
        });
  
        minButton.addEventListener("click", function () {
          close();
          toggleState();
          setTimeout(function () {
            show(isPrev, cId, pId, fId);
          }, parseDuration(closeDuration));
        });
  
        var selfObject = {
          subscribe: function (subCallback) {
            subscriptionCallbacks.push(subCallback);
          },
          show: show,
          close: close,
          isOpen: function () {
            return status.open;
          },
          getPopup: function () {
            return init.then(function () {
              return popup;
            });
          },
        };
        return selfObject;
      }
  
      function rvtsProductAlert(params, popupId, popupName, custId) {
        var settings = params.productAlertSettings;
        var querySelector = settings.querySelector
          ? settings.querySelector
          : ".rvts_product_alert";
        var insertPosition = settings.insertPosition
          ? settings.insertPosition
          : "replace";
        var selectedElement = document.querySelector(querySelector);
        if (!selectedElement) return;
        var currentProduct =
          typeof rvtsSWCurrentProduct !== "undefined"
            ? rvtsSWCurrentProduct
            : null;
        var productStockCount = currentProduct ? currentProduct.stockCount : null;
        if (productStockCount == 0) return;
        var productIdList = settings.productIdList.map((e) =>
          decodeURIComponent(e).toLocaleLowerCase().trim()
        );
        var productNameList = settings.productNameList.map((e) =>
          decodeURIComponent(e).toLocaleLowerCase().trim()
        );
        var productNameExcludeList = settings.productNameExcludeList.map((e) =>
          decodeURIComponent(e).toLocaleLowerCase().trim()
        );
        productIdList = productIdList.filter((e) => e);
        productNameList = productNameList.filter((e) => e);
        productNameExcludeList = productNameExcludeList.filter((e) => e);
        var productId = currentProduct
          ? currentProduct.p_id.toString().toLocaleLowerCase()
          : null;
        var productName = currentProduct
          ? currentProduct.name.toLocaleLowerCase()
          : window.location.href;
        var productIdMatch = false;
        var productNameMatch = false;
        var productNameExcludeMatch = false;
        productNameExcludeList.forEach((name) => {
          if (productName.includes(name)) {
            productNameExcludeMatch = true;
          }
        });
        if (productNameExcludeList.length > 0 && productNameExcludeMatch) return;
        if (productId) {
          productIdList.forEach((id) => {
            if (productId == id) productIdMatch = true;
          });
        } else {
          productIdMatch = true;
        }
        productNameList.forEach((name) => {
          if (productName.includes(name)) {
            productNameMatch = true;
          }
        });
        if (productIdList.length === 0) productIdMatch = true;
        if (productNameList.length === 0) productNameMatch = true;
        if (!productIdMatch && productNameList.length === 0) return;
        if (!productNameMatch && productIdList.length === 0) return;
        if (!productIdMatch && !productNameMatch) return;
        var contentDiv = document.createElement("div");
        var content = document.createElement("div");
        if (
          productStockCount &&
          parseInt(productStockCount) < parseInt(settings.stockCount)
        ) {
          content.innerHTML = decodeURIComponent(settings.content).replace(
            "[STOCK-COUNT]",
            productStockCount
          );
        } else {
          content.innerHTML = decodeURIComponent(settings.content).replace(
            "[STOCK-COUNT]",
            settings.stockWord
          );
        }
        contentDiv.appendChild(content);
  
        if (insertPosition === "replace") {
          selectedElement.parentElement.replaceChild(contentDiv, selectedElement);
        } else {
          selectedElement.insertAdjacentElement(insertPosition, contentDiv);
        }
  
        if (
          settings.showProgressBar &&
          productStockCount &&
          parseInt(productStockCount) < parseInt(settings.stockCount)
        ) {
          var maxBarWidth = content.getBoundingClientRect().width;
          if (maxBarWidth > 300) maxBarWidth = 300;
          var progressBG = null;
          var progressFill = null;
          var percentage = Math.round(
            (parseInt(productStockCount) / parseInt(settings.stockCount)) * 100
          );
          var fillWidth = Math.round((maxBarWidth * percentage) / 100);
          var progressBar = document.createElement("div");
          progressBar.innerHTML =
            '<div id="progressBG" style="transition:width 1s;margin-top:10px; width: 0;height: 10px;background-color: ' +
            settings.progressBGColor +
            ';border-radius: 10px;"><div id="progressFill" style="transition:width 1s;position: absolute;width: 0;height: 10px;background-color: ' +
            settings.progressFillColor +
            ';border-radius: 10px;"></div></div>';
          progressBG = progressBar.firstElementChild;
          progressFill = progressBG.firstElementChild;
          contentDiv.appendChild(progressBar);
          if (document.readyState === "complete") {
            setTimeout(function () {
              progressBG.style.width = maxBarWidth + "px";
            }, 1);
            setTimeout(function () {
              progressFill.style.width = fillWidth + "px";
            }, 250);
          } else {
            window.addEventListener("load", () => {
              setTimeout(function () {
                progressBG.style.width = maxBarWidth + "px";
              }, 1);
              setTimeout(function () {
                progressFill.style.width = fillWidth + "px";
              }, 250);
            });
          }
        }
        var fetchParams =
          "cust_id=" +
          custId +
          "&popup_id=" +
          popupId +
          "&form_id=0&user_agent=" +
          navigator.userAgent +
          "&activity_type=0" +
          "&session_id=" +
          rvtsSessionId;
        if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
        if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
        if (/Mobi|Android/i.test(navigator.userAgent)) {
          fetchParams += "&device=" + "1";
        } else {
          fetchParams += "&device=" + "2";
        }
        fetchParams +=
          "&url=" + window.location.href.split("&").join(encodeURIComponent("&"));
        fetch(
          "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
            fetchParams
        );
        rvtsPushGaEvent(0, popupName);
  
        return contentDiv;
      }
  
      async function rvtsSocialProof(
        params,
        popupId,
        popupName,
        custId,
        rcpLink,
        isPreview
      ) {
        var proofType = null;
        var recoFetched = false;
        var swParams = Object.assign({}, params);
        var scpSettings = params.socialProofSettings;
  
        var HTML = "<div>" + decodeURIComponent(scpSettings.content) + "</div>";
        var currentProduct = null;
        var recoType = {
          50: "[TOP_SELLER_PRODUCT]",
          60: "[PRICE_DROP_PRODUCT]",
          70: "[NEW_ARRIVAL_PRODUCT]",
        };
        for (var objKey in recoType) {
          if (HTML.includes(recoType[objKey])) {
            var product = await fetch(
              "https://" +
                rcpLink +
                "/rrcp/imc/recommendation/get_recommendation.jsp?cust_id=" +
                custId +
                "&type=" +
                objKey +
                "&limit=50"
            )
              .then((resp) => resp.json())
              .then((resp) => {
                var maxNum = resp.length - 1;
                var randNumber = Math.floor(Math.random() * (maxNum + 1));
                return resp[randNumber][0];
              })
              .catch((e) => {});
            if (product) {
              currentProduct = product;
              var tempURL = new URL(product.link);
              var tempLink = product.link;
  
              if (scpSettings.socialProofUTM) {
                if (tempURL.search) tempLink += "&";
                else tempLink += "?";
                tempLink +=
                  "utm_source=revotas&utm_medium=sw&utm_campaign=socialproof";
              }
  
              HTML = HTML.split(recoType[objKey]).join(
                '<a style="color:inherit;" href="' +
                  tempLink +
                  '">' +
                  product.name +
                  "</a>"
              );
              recoFetched = true;
              proofType = objKey;
            } else {
              return;
            }
            break;
          }
        }
        if (!currentProduct)
          currentProduct =
            typeof rvtsSWCurrentProduct !== "undefined"
              ? rvtsSWCurrentProduct
              : null;
        var productId = currentProduct
          ? currentProduct.p_id.toString().toLocaleLowerCase()
          : null;
        var productName = currentProduct
          ? currentProduct.name.toLocaleLowerCase()
          : window.location.href;
        var productIdList = scpSettings.productIdList.map((e) =>
          decodeURIComponent(e).toLocaleLowerCase().trim()
        );
        var productNameList = scpSettings.productNameList.map((e) =>
          decodeURIComponent(e).toLocaleLowerCase().trim()
        );
        var productNameExcludeList = scpSettings.productNameExcludeList.map((e) =>
          decodeURIComponent(e).toLocaleLowerCase().trim()
        );
        productIdList = productIdList.filter((e) => e);
        productNameList = productNameList.filter((e) => e);
        productNameExcludeList = productNameExcludeList.filter((e) => e);
        var productIdMatch = false;
        var productNameMatch = false;
        var productNameExcludeMatch = false;
        productNameExcludeList.forEach((name) => {
          if (productName.includes(name)) {
            productNameExcludeMatch = true;
          }
        });
        if (productNameExcludeList.length > 0 && productNameExcludeMatch) return;
        if (productId) {
          productIdList.forEach((id) => {
            if (productId == id) productIdMatch = true;
          });
        } else {
          productIdMatch = true;
        }
        productNameList.forEach((name) => {
          if (productName.includes(name)) {
            productNameMatch = true;
          }
        });
        if (productIdList.length === 0) productIdMatch = true;
        if (productNameList.length === 0) productNameMatch = true;
        if (!productIdMatch && productNameList.length === 0) return;
        if (!productNameMatch && productIdList.length === 0) return;
        if (!productIdMatch && !productNameMatch) return;
  
        var ipAddress = null;
        var locationObj = null;
        var locationEnabled = false;
  
        if (!isPreview || currentProduct || scpSettings.pageViewReferrer) {
          if (
            HTML.includes("[TOTAL_ORDER]") &&
            scpSettings.randomizeTotalOrder == 0
          ) {
            //Fetch order count
            if (!recoFetched) proofType = "order";
            if (!productId) return;
            var orderCount = await fetch(
              "https://" +
                rcpLink +
                "/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id=" +
                custId +
                "&type=order&product_id=" +
                productId
            )
              .then((resp) => resp.text())
              .then((resp) => resp.trim());
            if (orderCount > 0)
              HTML = HTML.split("[TOTAL_ORDER]").join(orderCount);
            else {
              var orderCountMax = parseInt(scpSettings.orderCountMax);
              var orderCountMin = parseInt(scpSettings.orderCountMin);
              var randNumber =
                Math.floor(Math.random() * (orderCountMax - orderCountMin + 1)) +
                orderCountMin;
              var storageObject = localStorage.getItem(
                "rvts_total_order_" + productId
              );
              if (storageObject) {
                storageObject = JSON.parse(storageObject);
                var now = new Date();
                now.setHours(0, 0, 0, 0);
                var backupDate = new Date(storageObject.date);
                backupDate.setHours(0, 0, 0, 0);
                var dayDiff = Math.round(
                  (now.getTime() - backupDate.getTime()) / (1000 * 60 * 60 * 24)
                );
                if (dayDiff == 0 && !recoFetched)
                  randNumber =
                    storageObject.number +
                    (Math.floor(Math.random() * 10) == 1 ? 1 : 0);
              }
              HTML = HTML.split("[TOTAL_ORDER]").join(randNumber);
              localStorage.setItem(
                "rvts_total_order_" + productId,
                JSON.stringify({ number: randNumber, date: new Date() })
              );
            }
          } else if (
            HTML.includes("[TOTAL_ORDER]") &&
            scpSettings.randomizeTotalOrder == 1
          ) {
            //Randomize order count
            if (!recoFetched) proofType = "order";
            if (!productId) return;
            var orderCountMax = parseInt(scpSettings.orderCountMax);
            var orderCountMin = parseInt(scpSettings.orderCountMin);
            var randNumber =
              Math.floor(Math.random() * (orderCountMax - orderCountMin + 1)) +
              orderCountMin;
            var storageObject = localStorage.getItem(
              "rvts_total_order_" + productId
            );
            if (storageObject) {
              storageObject = JSON.parse(storageObject);
              var now = new Date();
              now.setHours(0, 0, 0, 0);
              var backupDate = new Date(storageObject.date);
              backupDate.setHours(0, 0, 0, 0);
              var dayDiff = Math.round(
                (now.getTime() - backupDate.getTime()) / (1000 * 60 * 60 * 24)
              );
              if (dayDiff == 0 && !recoFetched)
                randNumber =
                  storageObject.number +
                  (Math.floor(Math.random() * 10) == 1 ? 1 : 0);
            }
            HTML = HTML.split("[TOTAL_ORDER]").join(randNumber);
            localStorage.setItem(
              "rvts_total_order_" + productId,
              JSON.stringify({ number: randNumber, date: new Date() })
            );
          }
          if (
            HTML.includes("[TOTAL_CART]") &&
            scpSettings.randomizeTotalCart == 0
          ) {
            //Fetch cart count
            if (!recoFetched) proofType = "cart";
            if (!productId) return;
            var cartCount = await fetch(
              "https://" +
                rcpLink +
                "/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id=" +
                custId +
                "&type=cart&product_id=" +
                productId
            )
              .then((resp) => resp.text())
              .then((resp) => resp.trim());
            if (cartCount > 0) HTML = HTML.split("[TOTAL_CART]").join(cartCount);
            else {
              var cartCountMax = parseInt(scpSettings.cartCountMax);
              var cartCountMin = parseInt(scpSettings.cartCountMin);
              var randNumber =
                Math.floor(Math.random() * (cartCountMax - cartCountMin + 1)) +
                cartCountMin;
              var storageObject = localStorage.getItem(
                "rvts_total_cart_" + productId
              );
              if (storageObject) {
                storageObject = JSON.parse(storageObject);
                var now = new Date();
                now.setHours(0, 0, 0, 0);
                var backupDate = new Date(storageObject.date);
                backupDate.setHours(0, 0, 0, 0);
                var dayDiff = Math.round(
                  (now.getTime() - backupDate.getTime()) / (1000 * 60 * 60 * 24)
                );
                if (dayDiff == 0 && !recoFetched)
                  randNumber =
                    storageObject.number +
                    (Math.floor(Math.random() * 10) == 1 ? 1 : 0);
              }
              HTML = HTML.split("[TOTAL_CART]").join(randNumber);
              localStorage.setItem(
                "rvts_total_cart_" + productId,
                JSON.stringify({ number: randNumber, date: new Date() })
              );
            }
          } else if (
            HTML.includes("[TOTAL_CART]") &&
            scpSettings.randomizeTotalCart == 1
          ) {
            //Randomize cart count
            if (!recoFetched) proofType = "cart";
            if (!productId) return;
            var cartCountMax = parseInt(scpSettings.cartCountMax);
            var cartCountMin = parseInt(scpSettings.cartCountMin);
            var randNumber =
              Math.floor(Math.random() * (cartCountMax - cartCountMin + 1)) +
              cartCountMin;
            var storageObject = localStorage.getItem(
              "rvts_total_cart_" + productId
            );
            if (storageObject) {
              storageObject = JSON.parse(storageObject);
              var now = new Date();
              now.setHours(0, 0, 0, 0);
              var backupDate = new Date(storageObject.date);
              backupDate.setHours(0, 0, 0, 0);
              var dayDiff = Math.round(
                (now.getTime() - backupDate.getTime()) / (1000 * 60 * 60 * 24)
              );
              if (dayDiff == 0 && !recoFetched)
                randNumber =
                  storageObject.number +
                  (Math.floor(Math.random() * 10) == 1 ? 1 : 0);
            }
            HTML = HTML.split("[TOTAL_CART]").join(randNumber);
            localStorage.setItem(
              "rvts_total_cart_" + productId,
              JSON.stringify({ number: randNumber, date: new Date() })
            );
          }
          if (
            HTML.includes("[TOTAL_PAGE_VIEW]") &&
            scpSettings.randomizeTotalPageView == 0
          ) {
            //Fetch page view count
            if (!recoFetched) proofType = "pageview";
            var pageViewCount = await fetch(
              "https://" +
                rcpLink +
                "/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id=" +
                custId +
                "&type=pageView&ref_link=" +
                (scpSettings.pageViewReferrer
                  ? scpSettings.pageViewReferrer
                  : window.location.href)
            )
              .then((resp) => resp.text())
              .then((resp) => resp.trim());
            if (pageViewCount > 0)
              HTML = HTML.split("[TOTAL_PAGE_VIEW]").join(pageViewCount);
            else {
              var pageViewCountMax = parseInt(scpSettings.pageViewCountMax);
              var pageViewCountMin = parseInt(scpSettings.pageViewCountMin);
              var randNumber =
                Math.floor(
                  Math.random() * (pageViewCountMax - pageViewCountMin + 1)
                ) + pageViewCountMin;
              var storageObject = localStorage.getItem("rvts_total_page_view");
              if (storageObject) {
                storageObject = JSON.parse(storageObject);
                var now = new Date();
                now.setHours(0, 0, 0, 0);
                var backupDate = new Date(storageObject.date);
                backupDate.setHours(0, 0, 0, 0);
                var dayDiff = Math.round(
                  (now.getTime() - backupDate.getTime()) / (1000 * 60 * 60 * 24)
                );
                if (dayDiff == 0)
                  randNumber =
                    storageObject.number +
                    (scpSettings.pageViewReferrer
                      ? Math.floor(Math.random() * 5) == 1
                        ? 1
                        : 0
                      : 1);
              }
              HTML = HTML.split("[TOTAL_PAGE_VIEW]").join(randNumber);
              localStorage.setItem(
                "rvts_total_page_view",
                JSON.stringify({ number: randNumber, date: new Date() })
              );
            }
          } else if (
            HTML.includes("[TOTAL_PAGE_VIEW]") &&
            scpSettings.randomizeTotalPageView == 1
          ) {
            //Randomize page view
            if (!recoFetched) proofType = "pageview";
            var pageViewCountMax = parseInt(scpSettings.pageViewCountMax);
            var pageViewCountMin = parseInt(scpSettings.pageViewCountMin);
            var randNumber =
              Math.floor(
                Math.random() * (pageViewCountMax - pageViewCountMin + 1)
              ) + pageViewCountMin;
            var storageObject = localStorage.getItem("rvts_total_page_view");
            if (storageObject) {
              storageObject = JSON.parse(storageObject);
              var now = new Date();
              now.setHours(0, 0, 0, 0);
              var backupDate = new Date(storageObject.date);
              backupDate.setHours(0, 0, 0, 0);
              var dayDiff = Math.round(
                (now.getTime() - backupDate.getTime()) / (1000 * 60 * 60 * 24)
              );
              if (dayDiff == 0)
                randNumber =
                  storageObject.number +
                  (scpSettings.pageViewReferrer
                    ? Math.floor(Math.random() * 5) == 1
                      ? 1
                      : 0
                    : 1);
            }
            HTML = HTML.split("[TOTAL_PAGE_VIEW]").join(randNumber);
            localStorage.setItem(
              "rvts_total_page_view",
              JSON.stringify({ number: randNumber, date: new Date() })
            );
          }
          if (HTML.includes("[TOTAL_PRODUCT_VIEW]")) {
            if (!recoFetched) proofType = "productview";
            if (!productId) return;
            var productViewCountMax = parseInt(scpSettings.productViewCountMax);
            var productViewCountMin = parseInt(scpSettings.productViewCountMin);
            var randNumber =
              Math.floor(
                Math.random() * (productViewCountMax - productViewCountMin + 1)
              ) + productViewCountMin;
            var storageObject = localStorage.getItem("rvts_total_product_view");
            if (storageObject) {
              storageObject = JSON.parse(storageObject);
              var now = new Date();
              now.setHours(0, 0, 0, 0);
              var backupDate = new Date(storageObject.date);
              backupDate.setHours(0, 0, 0, 0);
              var dayDiff = Math.round(
                (now.getTime() - backupDate.getTime()) / (1000 * 60 * 60 * 24)
              );
              if (dayDiff == 0 && !recoFetched)
                randNumber = storageObject.number + 1;
            }
            HTML = HTML.split("[TOTAL_PRODUCT_VIEW]").join(randNumber);
            localStorage.setItem(
              "rvts_total_product_view",
              JSON.stringify({ number: randNumber, date: new Date() })
            );
          }
          if (HTML.includes("[LAST_ORDER_CITY]")) {
            locationEnabled = true;
            /*if(typeof google === 'undefined' ||  typeof google.maps.Map !== 'function') {
                      var gMapScript = document.createElement('script');
                      gMapScript.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyDcyjL_de1Z6RmtsYO-nGOQzk0WpHvPggA&callback=rvtsSocialProofInitMap';
                      document.head.appendChild(gMapScript);
                      await rvtsMapInitialized;
                  }*/
            if (!localStorage.getItem("rvts_ip_list")) {
              var ipAddressList = await fetch(
                "https://" +
                  rcpLink +
                  "/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id=" +
                  custId +
                  "&type=ipList"
              ).then((resp) => resp.json());
              localStorage.setItem("rvts_ip_list", JSON.stringify(ipAddressList));
              var maxNum = ipAddressList.length - 1;
              var randNumber = Math.floor(Math.random() * (maxNum + 1));
              ipAddress = ipAddressList[randNumber];
            } else {
              var ipAddressList = JSON.parse(
                localStorage.getItem("rvts_ip_list")
              );
              var maxNum = ipAddressList.length - 1;
              var randNumber = Math.floor(Math.random() * (maxNum + 1));
              ipAddress = ipAddressList[randNumber];
            }
  
            locationObj = await fetch(
              "https://pro.ip-api.com/json/" + ipAddress + "?key=meqxcbbXZfQRbIa"
            )
              .then((resp) => resp.json())
              .then((resp) => {
                return {
                  lng: resp.lon,
                  lat: resp.lat,
                  city: resp.city,
                };
              });
            HTML = HTML.split("[LAST_ORDER_CITY]").join(locationObj.city);
          }
        } else {
          if (HTML.includes("[LAST_ORDER_CITY]")) {
            locationEnabled = true;
            /*if(typeof google === 'undefined' ||  typeof google.maps.Map !== 'function') {
                      var gMapScript = document.createElement('script');
                      gMapScript.src = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyDcyjL_de1Z6RmtsYO-nGOQzk0WpHvPggA&callback=rvtsSocialProofInitMap';
                      document.head.appendChild(gMapScript);
                      await rvtsMapInitialized;
                  }*/
            if (!localStorage.getItem("rvts_ip_list")) {
              var ipAddressList = await fetch(
                "https://" +
                  rcpLink +
                  "/rrcp/imc/smartwidgets/get_order_cart_count.jsp?cust_id=" +
                  custId +
                  "&type=ipList"
              ).then((resp) => resp.json());
              localStorage.setItem("rvts_ip_list", JSON.stringify(ipAddressList));
              var maxNum = ipAddressList.length - 1;
              var randNumber = Math.floor(Math.random() * (maxNum + 1));
              ipAddress = ipAddressList[randNumber];
            } else {
              var ipAddressList = JSON.parse(
                localStorage.getItem("rvts_ip_list")
              );
              var maxNum = ipAddressList.length - 1;
              var randNumber = Math.floor(Math.random() * (maxNum + 1));
              ipAddress = ipAddressList[randNumber];
            }
            locationObj = await fetch(
              "https://pro.ip-api.com/json/" + ipAddress + "?key=meqxcbbXZfQRbIa"
            )
              .then((resp) => resp.json())
              .then((resp) => {
                return {
                  lng: resp.lon,
                  lat: resp.lat,
                  city: resp.city,
                };
              });
            HTML = HTML.split("[LAST_ORDER_CITY]").join(locationObj.city);
          }
          if (HTML.includes("[TOTAL_ORDER]")) proofType = "order";
          if (HTML.includes("[TOTAL_CART]")) proofType = "cart";
          if (HTML.includes("[TOTAL_PAGE_VIEW]")) proofType = "pageview";
          if (HTML.includes("[TOTAL_PRODUCT_VIEW]")) proofType = "productview";
          HTML = HTML.split("[TOTAL_ORDER]").join(50);
          HTML = HTML.split("[TOTAL_PAGE_VIEW]").join(50);
          HTML = HTML.split("[TOTAL_PRODUCT_VIEW]").join(50);
          HTML = HTML.split("[TOTAL_CART]").join(50);
        }
  
        // specify the widget size
        let widgetSize = scpSettings.widgetSize;
        widgetSize === 0
          ? (widgetSize = "smallDesign")
          : widgetSize === 1
          ? (widgetSize = "mediumDesign")
          : (widgetSize = "largeDesign");
  
        var defaultPicture =
          "http://l.revotas.com/trc/Host/socialProof/icon1.svg";
        var bgColor = "#ff6600";
        if (proofType == 50) {
          defaultPicture = "https://l.revotas.com/trc/Host/socialProof/icon4.svg";
          var bgColor = "#fff";
        } else if (proofType == 60) {
          defaultPicture = "https://l.revotas.com/trc/Host/socialProof/icon3.svg";
          var bgColor = "#fff";
        } else if (proofType == 70) {
          defaultPicture = "https://l.revotas.com/trc/Host/socialProof/icon6.svg";
          var bgColor = "#fff";
        } else if (proofType == "order") {
          defaultPicture = "https://l.revotas.com/trc/Host/socialProof/icon7.svg";
          var bgColor = "#fff";
        } else if (proofType == "cart") {
          defaultPicture =
            "https://revocdn.revotas.com/trc/smartwidget/total-cart.png";
          var bgColor = "#fff";
        } else if (proofType == "pageview") {
          defaultPicture = "https://l.revotas.com/trc/Host/socialProof/icon1.svg";
          var bgColor = "#fff";
        } else if (proofType == "productview") {
          defaultPicture = "https://l.revotas.com/trc/Host/socialProof/icon8.svg";
          var bgColor = "#fff";
        }
  
        function createElement(tag, attributes, parent, innerHTML) {
          const element = document.createElement(tag);
          Object.entries(attributes).forEach(([key, value]) => {
            element.setAttribute(key, value);
          });
          if (innerHTML) element.innerHTML = innerHTML;
          parent.appendChild(element);
          return element;
        }
  
        createElement(
          "link",
          {
            rel: "stylesheet",
            href: "https://fonts.googleapis.com/css2?family=Poppins:wght@100;200;900&display=swap",
          },
          document.head
        );
  
        var socialProofHTML = `
      
              <style> 
      
      
      
              
                
             
              .revotas-social-proof-widget,
              .revotas-social-proof-widget *,
              .revotas-social-proof-widget *::before,
              .revotas-social-proof-widget *::after {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
                font-family: "Poppins", sans-serif;
                color: inherit;
                line-height: inherit;
                user-select: none;
              } 
      
      
              .revotas-social-proof-widget__icon {
                  margin: 0 !important;
              }
      
              /* eger background degistirilebilir hale gelirse bu satir kaldırılacak !!! su anda sadece beyaz renk alırız bu kod ile panelden gelen content icin  panelden siyah renk gelse bile beyaza donusecektir*/
      
              .revotas-social-proof-widget font {
                  font-weight: 200 !important;
                  color: white !important;
                  font-size: ${
                    widgetSize === "smallDesign"
                      ? "12px"
                      : widgetSize === "mediumDesign"
                      ? "14px"
                      : "18px"
                  } !important;
              }
      
              .revotas-social-proof-widget__info div font span {
                  font-size: 18px;
                  color: white !important;
                  font-family: "Poppins", sans-serif !important;
              }
              
      
              .revotas-social-proof {
              }
              .revotas-social-proof-widget img {
                pointer-events: none;
              }
              
              .revotas-social-proof-widget p {
                margin: 0;
                line-height: 1.2;
              }
              
              .revotas-social-proof-widget {
                color: white; /* Default color */
                line-height: 1.5; /* Default line height */
              }
              
              .revotas-social-proof-widget,
              .revotas-social-proof-widget__wrapper {
                --radius: 32px;
                border-radius: var(--radius);
              }
      
              
              /* Custom styles */
              .revotas-social-proof-widget__wrapper {
                z-index: 999999;
                background-color: #333;
                height: auto;
                display: flex;
                gap: 14px;
                padding: 16px;
                max-width: 390px;
                width: 100%;
                align-items: center;
                justify-content: center;
                background: linear-gradient(-90deg, #e97c14, #de6290, #e97c14, #de6290);
                background-size: 200% 200% ;
                animation: gradient 6s ease infinite ;
              }
      
      
             
                
                @media (max-width: 768px) {
                  .revotas-social-proof__close {
                    right: 5%;
                    top: -10%;
                  }
                }
                
                .revotas-social-proof__close:hover {
                  transform: rotate(360deg);
                  transition: 0.5s ease;
                }
                
              
            
              
              .revotas-social-proof-widget__icon img {
                display: block;
                max-width: ${
                  widgetSize === "smallDesign"
                    ? "32px"
                    : widgetSize === "mediumDesign"
                    ? "42px"
                    : "66px"
                };
                max-height: 42px;
                width: 100%;
                height: auto;
              }
              
              .revotas-social-proof-widget__info p {
                margin: 0;
              }
              
              .revotas-social-proof-widget__wrapper .revotas-social-proof-widget__info p {
                font-size: 18px;
                font-weight: 200;
              }
              
              @media (max-width: 768px) {
                .revotas-social-proof-widget__wrapper .revotas-social-proof-widget__info p {
                  font-size: 16px !important;
                }
              
                .revotas-social-proof-widget__wrapper {
                  gap: 0 !important;
                }
                .revotas-social-proof-widget__icon {
                  margin-right: 8px !important;
                }
              }
              
              @media (max-width: 640px) {
                .revotas-social-proof-widget__wrapper .revotas-social-proof-widget__info p {
                  font-size: 14px;
                }
              }
              
              @media (max-width: 367px) {
                .revotas-social-proof-widget__wrapper .revotas-social-proof-widget__info p {
                  font-size: 12px;
                }
              }
              
              @media (max-width: 309px) {
                .revotas-social-proof-widget__wrapper {
                  flex-direction: column;
                  gap: 8px;
                  text-align: center;
                }
              }
      
              .smart-widget-container-div {
                  overflow: visible !important;
              }
      
      
              .revotas-social-proof__close {
                  z-index: 999999;
                  cursor: pointer;
                  position: absolute;
                  right: 2%;
                  top: ${
                    widgetSize === "smallDesign"
                      ? "-6%"
                      : widgetSize === "mediumDesign"
                      ? "-8%"
                      : "-10%"
                  };
                  width: ${
                    widgetSize === "smallDesign"
                      ? "16px"
                      : widgetSize === "mediumDesign"
                      ? "20px"
                      : "24px"
                  };
                  height: ${
                    widgetSize === "smallDesign"
                      ? "16px"
                      : widgetSize === "mediumDesign"
                      ? "20px"
                      : "24px"
                  };
                  z-index: 999999;
                  cursor: pointer;
                  background-color: white;
                  border-radius: 50%;
                  display: grid;
                  place-content: center;
                  margin: 10px;
                }
      
              .social-proof-container {
                  margin: 10px;
              }
      
              ${
                decodeURIComponent(scpSettings.socialProofCss).includes(
                  "@keyframes gradient"
                )
                  ? ""
                  : `
              
              @keyframes gradient {
                  0% {
                    background-position: 0% 50%;
                  }
                  50% {
                    background-position: 100% 50%;
                  }
                  100% {
                    background-position: 0% 50%;
                  }
                }
      
              `
              }
      
      
              ${decodeURIComponent(scpSettings.socialProofCss)}
      
              
              </style> 
              <meta charset="utf-8"> 
              <div style="width: auto !important; height: auto !important;" class="social-proof-container"> 
              <div class="revotas-social-proof-widget">
              <div id="revotas-social" class="revotas-social-proof-widget__wrapper">
                     
                <figure
                  style="${scpSettings.showIcon === false ? "" : ""}"
                  class="revotas-social-proof-widget__icon"
                >
                  <img src="${defaultPicture}" alt="icon" />
                </figure>
                <div class="revotas-social-proof-widget__info">${HTML}</div>
              </div>
            </div>
              </div>`;
  
        swParams.type = scpSettings.animationType;
        swParams.height = "auto";
        swParams.width = "auto";
        swParams.backgroundColor = scpSettings.backgroundColor;
        swParams.hAlign = "center";
        swParams.vAlign = "center";
        swParams.autoCloseDelay = scpSettings.autoCloseDelay;
        swParams.showDuration = scpSettings.showDuration;
        swParams.closeDuration = scpSettings.closeDuration;
        swParams.contentType = "htmlCode";
        swParams.html = socialProofHTML;
        if (swParams.type === "sliding") {
          swParams.startPosition = scpSettings.startPosition;
          swParams.endPosition = scpSettings.endPosition;
        } else if (swParams.type === "fading") {
          swParams.position = scpSettings.position;
        }
        delete swParams["socialProofSettings"];
  
        var div = document.createElement("div");
        div.className = "revotas-social-proof__close";
  
        // SVG'yi oluştur
        var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        svg.setAttribute(
          "width",
          `${
            widgetSize === "smallDesign"
              ? "12"
              : widgetSize === "mediumDesign"
              ? "16"
              : "24"
          }`
        );
        svg.setAttribute(
          "height",
          `${
            widgetSize === "smallDesign"
              ? "12"
              : widgetSize === "mediumDesign"
              ? "16"
              : "24"
          }`
        );
        svg.setAttribute("viewBox", "0 0 24 24");
  
        // Path'i oluştur
        var path = document.createElementNS("http://www.w3.org/2000/svg", "path");
        path.setAttribute("fill", "#D96961");
        path.setAttribute(
          "d",
          "M12 10.586l-4.293-4.293-1.414 1.414 4.293 4.293-4.293 4.293 1.414 1.414 4.293-4.293 4.293 4.293 1.414-1.414-4.293-4.293 4.293-4.293-1.414-1.414-4.293 4.293z"
        );
  
        svg.appendChild(path);
  
        div.appendChild(svg);
  
        customButton = div;
        // customButton.style.display = 'none';
        var popup = null;
        if (swParams.type === "sliding")
          popup = slidingPopup(swParams, popupId, customButton, popupName);
        else if (swParams.type === "fading")
          popup = fadingPopup(swParams, popupId, customButton, popupName);
        if (locationEnabled) {
          await popup.getPopup().then((popupDiv) => {
            popupDiv.querySelector(".social-proof-icon").style.overflow =
              "hidden";
            popupDiv.querySelector(".social-proof-icon").innerHTML =
              '<img style="width:500% !important;height:500% !important; max-width: 500% !important; max-height: 500% !important;" src="https://l.revotas.com/trc/Host/socialProof/icon1.svg" />';
            /*var map = new google.maps.Map(popupDiv.querySelector('.social-proof-icon'), {
                      center: { lat:locationObj.lat, lng: locationObj.lng },
                      scrollwheel: false,
                      zoom: 10,
                      draggable: false,
                      disableDefaultUI: true,
                      clickableIcons:false
                  });*/
          });
        }
  
        if (!isPreview) {
          popup.getPopup().then((popupDiv) => {
            Array.from(popupDiv.querySelectorAll("a")).forEach((link) => {
              link.addEventListener("click", function () {
                var fetchParams = "";
                fetchParams += "cust_id=" + custId;
                fetchParams += "&popup_id=" + popupId;
                fetchParams += "&form_id=0";
                fetchParams += "&user_agent=" + navigator.userAgent;
                fetchParams += "&activity_type=1";
                fetchParams += "&session_id=" + rvtsSessionId;
                if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
                if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                if (/Mobi|Android/i.test(navigator.userAgent)) {
                  fetchParams += "&device=" + "1";
                } else {
                  fetchParams += "&device=" + "2";
                }
                fetchParams +=
                  "&url=" +
                  window.location.href.split("&").join(encodeURIComponent("&"));
                fetch(
                  "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                    fetchParams
                );
                rvtsPushGaEvent(1, popupName);
                if (activityType == "1") saveSwSource(popupId);
              });
            });
          });
        }
        return popup;
      }
  
      function rvtsTestStoryImage(story) {
        return [
          new Promise((resolve, reject) => {
            var img = document.createElement("img");
            img.onerror = function () {
              story.invalid = true;
              resolve();
            };
            img.onload = function () {
              resolve();
            };
            img.src = story.url;
          }),
          new Promise((resolve, reject) => {
            var img = document.createElement("img");
            img.onerror = function () {
              story.invalid = true;
              resolve();
            };
            img.onload = function () {
              resolve();
            };
            img.src = story.preview;
          }),
        ];
      }
  
      function rvtsTestStoryImage(story) {
        return [
          new Promise((resolve, reject) => {
            var img = document.createElement("img");
            img.onerror = function () {
              story.invalid = true;
              resolve();
            };
            img.onload = function () {
              resolve();
            };
            img.src = story.url;
          }),
          new Promise((resolve, reject) => {
            var img = document.createElement("img");
            img.onerror = function () {
              story.invalid = true;
              resolve();
            };
            img.onload = function () {
              resolve();
            };
            img.src = story.preview;
          }),
        ];
      }
  
      function rvtsTestStoryVideo(story) {
        return [
          new Promise((resolve, reject) => {
            var video = document.createElement("video");
            var source = document.createElement("source");
            source.onerror = function () {
              story.invalid = true;
              resolve();
            };
            video.onloadedmetadata = function () {
              resolve();
            };
            source.type = "video/mp4";
            source.src = story.url;
            video.appendChild(source);
          }),
          new Promise((resolve, reject) => {
            var img = document.createElement("img");
            img.onerror = function () {
              story.invalid = true;
              resolve();
            };
            img.onload = function () {
              resolve();
            };
            img.src = story.preview;
          }),
        ];
      }
  
      async function rvtsStoryContainerLive(
        storyList,
        querySelector,
        position,
        isLivePreview,
        popupId,
        popupName,
        custId,
        appendUTM
      ) {
        var css =
          ".rvts-ig-story-frame{position: relative;width: 95%;height: 140px;display: flex;align-items: flex-start;margin: auto}.rvts-ig-story-list{position: absolute;left: 0;transition: left .5s ease 0s}.rvts-ig-story__container{max-width: 100%;height: 90px;display: flex;align-items: center}.rvts-ig-story{border: 1px solid #000;border-radius: 50%;height: 65px;width: 65px;margin-left: 20px;position: relative;display: flex;align-items: center;justify-content: center;overflow: hidden}.rvts-ig-story__image{width: 100%}.rvts-ig-story-overlay{z-index: " +
          (maxInt - 1) +
          ';position: fixed;left: 0;top: 0;width: 100vw;height: 100vh;background-color: #151515;display: flex;justify-content: center;align-items: center}.rvts-ig-story-viewer{position:relative;border: 1px solid #000;width: 300px;height: 80%}.rvts-ig-story-viewer__bar{width: 100%;height: 20px;display: flex;align-items: center;justify-content: space-around}.rvts-ig-story-viewer__bar>div{height: 2px;width: 100%;background-color: gray;margin: 0 1px;border-radius: 5px;position: relative}.rvts-ig-story-viewer__bar>div>div{position: absolute;transition: width .1s;transition-timing-function: linear;left: 0;background-color: #fff;top: 0;height: 100%;width: 0}.rvts-ig-story-viewer__container img,.rvts-ig-story-viewer__container video{width: 100%;height:auto;position: absolute}.rvts-ig-story-viewer__container>div:nth-child(1){top: 50%;left: -15px;position: absolute;color: #fff;cursor: pointer}.rvts-ig-story-viewer__container>div:nth-child(2){top: 50%;right: -15px;position: absolute;color: #fff;cursor: pointer}.rvts-ig-story-viewer__container>div:nth-child(4){position: absolute;bottom: 20px;width: 100%;display: flex;flex-direction: column;justify-content: center;align-items: center;z-index: 2;color: #fff;font-size: 40px;cursor: pointer;animation: rvtsMoveUpDown 1s linear infinite}@keyframes rvtsMoveUpDown{0%,100%{bottom: 3%}50%{bottom: 6%}}.rvts-ig-story-viewer__bar>div.active{background-color: #fff}.rvts-ig-story-viewer__container{width: 100%;height: calc(100% - 20px);background-color: #909090;position: relative;display:flex;align-items:center;justify-content:center;}.rvts-close-button{position: absolute;right: 3%;top: 2%;width: 30px;height: 30px;background-color: #ffffffab;border-radius: 3px;z-index: 2;cursor: pointer}.rvts-close-button:after,.rvts-close-button:before{position: absolute;left: 14px;content: " ";height: 20px;width: 2px;top: 6px;background-color: #333}.rvts-close-button:before{transform: rotate(45deg)}.rvts-close-button:after{transform: rotate(-45deg)}.rvts-up-arrow{border: solid #fff;border-width: 0 5px 5px 0;display: inline-block;padding: 10px;transform: rotate(-135deg);-webkit-transform: rotate(-135deg)}.rvts-up-arrow-container{background-color: #02020280;display: flex;justify-content: center;border-radius: 20px;align-items: center;width: 47px;height: 34px;padding-top: 12px}.rvts-cta-text-container{background-color: #02020280;display: flex;justify-content: center;border-radius: 10px;align-items: center;width: auto;height: auto;padding: 3px 10px}.rvts-arrow{border: solid #fff;border-width: 0 4px 4px 0;display: inline-block;padding: 7px;transform: rotate(135deg);-webkit-transform: rotate(135deg)}.rvts-arrow.left{transform: rotate(135deg);-webkit-transform: rotate(135deg)}.rvts-arrow.right{transform: rotate(-45deg);-webkit-transform: rotate(-45deg)}.rvts-ig-story__button{border-color: #fff;border-width: 0 2px 2px 0}.rvts-ig-story__button.left{left: 5px}.rvts-ig-story__button.right{right: 5px}.rvts-ig-story__button_container{background-color: #02020280;display: flex;justify-content: center;border-radius: 14px;align-items: center;width: 24px;height: 34px;position: absolute!important;cursor: pointer;z-index: 1}.rvts-ig-story__button_container.left{padding-left: 8px;left: 5px;top:28px;}.rvts-ig-story__button_container.right{padding-right: 8px;right: 5px;top:28px;}.media-files{margin: 20px 0;border: 1px solid #ced4da;border-radius: 5px;padding: 10px}.media-list{display: flex;height: 120px;overflow-x: auto;overflow-y: hidden;align-items: center}.media-div{background-color: white;cursor: pointer;border-radius: 50%;height: 75px;width: 75px;margin-left: 15px;display: flex;align-items: center;justify-content: center;overflow: hidden;z-index: 1}.media-div>img{width: 100%!important}.rvts-story-gradient{width: 87px;height: 87px;position: absolute;background: linear-gradient(180deg, #e29c2d, #fff0d8);top: -6px;left: 9px;border-radius: 50%}.rvts-story-background { background: white; width: 83px; height: 83px; top: -4px; left: 11px; border-radius: 50%; position: absolute; }.media-div+div{margin-left:12px;position:absolute!important;top:80px;height:52px;text-align:center;display:flex;align-items:center}.media-mini-image{max-width:100%;height:auto;}.media-mini-div { position:absolute;left:0;background-color: white; cursor: pointer; border-radius: 50%; height: 37px; width: 37px; display: flex; align-items: center; justify-content: center; overflow: hidden; z-index: 1; } .rvts-story-mini-gradient { width: 45px; height: 45px; position: absolute; top: -4px; left: -4px; border-radius: 50%; } .rvts-story-mini-background { background: white; width: 41px; height: 41px; top: -2px; left: -2px; border-radius: 50%; position: absolute; }';
  
        var isMobile = __smartWidgetConditionFunctions__.deviceType("mobile");
  
        if (isMobile) {
          css +=
            ".rvts-ig-story-viewer{width:100%;height:100vh;}.rvts-ig-story-frame{overflow:unset;overflow-y:scroll;scrollbar-width:none;-ms-overflow-style:none;}.rvts-ig-story-frame::-webkit-scrollbar{width:0;height:0;}.rvts-arrow{display:none;}.rvts-ig-story-viewer__container>div:nth-child(1){-webkit-tap-highlight-color: transparent;left:0;top:0;z-index:2;width:30%;height:100%;}.rvts-ig-story-viewer__container>div:nth-child(2){-webkit-tap-highlight-color: transparent;right:0;top:0;z-index:2;width:30%;height:100%;}@keyframes rvtsMoveUpDown{0%,100%{bottom: 12%}50%{bottom: 15%}}";
        } else {
          css += ".rvts-ig-story-frame{overflow:hidden;}";
        }
  
        /*var promiseArray = [];
          storyList.forEach(story => {
              if(story.type === 'image') {
                  promiseArray.push(...rvtsTestStoryImage(story));
              } else if(story.type === 'video') {
                  promiseArray.push(...rvtsTestStoryVideo(story));
              } else if(story.stories) {
                  story.stories.forEach(highlight => {
                      if(highlight.type === 'image') {
                          promiseArray.push(...rvtsTestStoryImage(highlight));
                      } else if(highlight.type === 'video') {
                          promiseArray.push(...rvtsTestStoryVideo(highlight));
                      }
                  });
              }
          });
          
          await Promise.all(promiseArray).then(()=>{
              var idxToRemove = [];
              storyList.forEach((s,i,arr)=>{
                  if(s.invalid && !idxToRemove.includes(i))idxToRemove.push(i);
              });
              storyList.forEach((s,i,arr)=>{
                  if(s.stories) {
                      s.stories = s.stories.filter(h=>!h.invalid);
                      if(s.stories.length===0 && !idxToRemove.includes(i))idxToRemove.push(i);
                  }
              });
              for(var idx = idxToRemove.length-1; idx>=0;idx--) {
                  storyList.splice(idxToRemove[idx],1);
              }
          });*/
  
        var elementWidth = 85;
        var elementSpace = 20;
        var divWidth =
          elementWidth * storyList.length + (storyList.length + 1) * elementSpace;
        var cssTag = document.createElement("style");
        cssTag.innerHTML = css;
        document.head.appendChild(cssTag);
  
        var mainDiv = document.createElement("div");
        if (storyList.length) mainDiv.classList.add("rvts-ig-story-frame");
        mainDiv.innerHTML =
          '<div class="rvts-ig-story-list"> <div class="rvts-ig-story__container"> </div> </div> <div class="rvts-ig-story__button_container left"><div class="rvts-ig-story__button left rvts-arrow left"></div></div> <div class="rvts-ig-story__button_container right"><div class="rvts-ig-story__button right rvts-arrow right"></div></div>';
        var leftArrow = mainDiv.querySelector(
          ".rvts-ig-story__button_container.left"
        );
        var rightArrow = mainDiv.querySelector(
          ".rvts-ig-story__button_container.right"
        );
        if (isMobile) {
          leftArrow.style.setProperty("display", "none", "important");
          rightArrow.style.setProperty("display", "none", "important");
        }
  
        var circleList = storyList.map((story, index) => {
          if (story.id && story.stories.length === 0) return null;
          var div = document.createElement("div");
          div.style.display = "flex";
          div.style.flexDirection = "column";
          div.style.alignItems = "center";
          div.style.transition = "top 1s ease 0s";
          div.style.top = "-125px";
          div.style.position = "relative";
          div.style.marginLeft = "5px";
          var circle = document.createElement("div");
          circle.classList.add("media-div");
          if (story.tvAlign)
            circle.style.setProperty("align-items", story.tvAlign, "important");
          var image = document.createElement("img");
          image.classList.add("media-image");
          image.src = story.preview ? story.preview : story.pictureUrl;
          circle.appendChild(image);
          circle.addEventListener("click", function () {
            if (!isLivePreview) {
              var fetchParams =
                "cust_id=" +
                custId +
                "&popup_id=" +
                popupId +
                "&form_id=0&user_agent=" +
                navigator.userAgent +
                "&activity_type=1" +
                "&session_id=" +
                rvtsSessionId;
              if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
              if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
              if (/Mobi|Android/i.test(navigator.userAgent)) {
                fetchParams += "&device=" + "1";
              } else {
                fetchParams += "&device=" + "2";
              }
              fetchParams +=
                "&url=" +
                window.location.href.split("&").join(encodeURIComponent("&"));
              fetch(
                "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                  fetchParams
              );
              rvtsPushGaEvent(1, popupName);
            }
            if (story.isLink == 1) {
              if (appendUTM === true) {
                var tempURL = new URL(story.ctaUrl);
                var tempLink = story.ctaUrl;
                if (tempURL.search) tempLink += "&";
                else tempLink += "?";
                tempLink +=
                  "utm_source=revotas&utm_medium=sw&utm_campaign=igstory";
                window.location = tempLink;
              } else {
                window.location = story.ctaUrl;
              }
            } else {
              if (story.id) {
                rvtsStoryViewerLive(
                  story,
                  0,
                  isLivePreview,
                  popupId,
                  popupName,
                  custId,
                  appendUTM
                );
              } else {
                var tempStoryList = storyList.filter((story) => !story.id);
                var index = tempStoryList.findIndex((e) => e === story);
                rvtsStoryViewerLive(
                  tempStoryList,
                  index,
                  isLivePreview,
                  popupId,
                  popupName,
                  custId,
                  appendUTM
                );
              }
            }
          });
          div.appendChild(circle);
          div.appendChild(
            (() => {
              var title = document.createElement("div");
              title.style.setProperty("line-height", "18px", "important");
              title.textContent = story.title ? story.title : "";
              return title;
            })()
          );
          div.appendChild(
            (() => {
              if (!story.color1) story.color1 = "#e29c2d";
              if (!story.color2) story.color2 = "#fff0d8";
              var backDiv = document.createElement("div");
              backDiv.classList.add("rvts-story-gradient");
              backDiv.style.background =
                "linear-gradient(180deg, " +
                story.color1 +
                ", " +
                story.color2 +
                ")";
              return backDiv;
            })()
          );
          div.appendChild(
            (() => {
              var backDiv = document.createElement("div");
              backDiv.classList.add("rvts-story-background");
              return backDiv;
            })()
          );
          return div;
        });
        var container = mainDiv.querySelector(".rvts-ig-story__container");
        var storyListDiv = mainDiv.querySelector(".rvts-ig-story-list");
  
        circleList.forEach((circle) => {
          if (circle) container.appendChild(circle);
        });
        leftArrow.addEventListener("click", function () {
          var l1 = mainDiv.getBoundingClientRect().left;
          var l2 = storyListDiv.getBoundingClientRect().left;
          var distance = l1 - l2 < 200 ? l1 - l2 : 200;
          storyListDiv.style.left =
            parseInt(getComputedStyle(storyListDiv).left) + distance + "px";
        });
        rightArrow.addEventListener("click", function () {
          var r1 = mainDiv.getBoundingClientRect().right;
          var r2 = storyListDiv.getBoundingClientRect().right + 20;
          var distance = r2 - r1 < 200 ? r2 - r1 : 200;
          storyListDiv.style.left =
            parseInt(getComputedStyle(storyListDiv).left) - distance + "px";
        });
  
        var lastWidthObj = (function () {
          var width = 0;
          return {
            setWidth: function (w) {
              width = w;
            },
            getWidth: function () {
              return width;
            },
          };
        })();
  
        if (position === "replace") {
          document
            .querySelector(querySelector)
            .parentElement.replaceChild(
              mainDiv,
              document.querySelector(querySelector)
            );
        } else {
          document
            .querySelector(querySelector)
            .insertAdjacentElement(position, mainDiv);
        }
  
        function animateStories() {
          circleList.forEach((circle, index) => {
            if (circle) {
              setTimeout(function () {
                circle.style.top = "0";
              }, index * 200);
            }
          });
        }
  
        if (document.readyState === "complete") {
          animateStories();
        } else {
          window.addEventListener("load", animateStories);
        }
  
        function resizeFunc() {
          var newWidth = mainDiv.parentElement.getBoundingClientRect().width;
          if (newWidth != lastWidthObj.getWidth()) {
            lastWidthObj.setWidth(newWidth);
            if (newWidth + 10 < divWidth) {
              mainDiv.style.width = "";
              if (!isMobile) {
                leftArrow.style.display = "";
                rightArrow.style.display = "";
              }
            } else {
              if (!isMobile) {
                leftArrow.style.display = "none";
                rightArrow.style.display = "none";
              }
              mainDiv.style.setProperty("width", divWidth + "px", "important");
            }
            storyListDiv.style.left = "0";
          }
        }
  
        window.addEventListener("resize", resizeFunc);
  
        resizeFunc();
  
        saveLastPopupShow(popupId);
        if (!isLivePreview) {
          var fetchParams =
            "cust_id=" +
            custId +
            "&popup_id=" +
            popupId +
            "&form_id=0&user_agent=" +
            navigator.userAgent +
            "&activity_type=0" +
            "&session_id=" +
            rvtsSessionId;
          if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
          if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
          fetchParams +=
            "&url=" +
            window.location.href.split("&").join(encodeURIComponent("&"));
          if (/Mobi|Android/i.test(navigator.userAgent)) {
            fetchParams += "&device=" + "1";
          } else {
            fetchParams += "&device=" + "2";
          }
          fetch(
            "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
              fetchParams
          );
          rvtsPushGaEvent(0, popupName);
        }
  
        return mainDiv;
      }
  
      function rvtsStoryViewerLive(
        storyList,
        index,
        isLivePreview,
        popupId,
        popupName,
        custId,
        appendUTM
      ) {
        var isMobile = __smartWidgetConditionFunctions__.deviceType("mobile");
        var wBG = document.createElement("div");
        wBG.style.setProperty("position", "fixed", "important");
        wBG.style.width = "100vw";
        wBG.style.height = "0vh";
        wBG.style.bottom = "0";
        wBG.style.setProperty("z-index", maxInt, "important");
        wBG.style.backgroundColor = "white";
        wBG.style.transition = "height 1s ease 0s";
        document.body.appendChild(wBG);
        var activeStory = null;
        var highlightDuration = null;
        var storyOverlay = document.createElement("div");
        storyOverlay.classList.add("rvts-ig-story-overlay");
        storyOverlay.setAttribute("ondragstart", "return false;");
        storyOverlay.setAttribute("ondrop", "return false;");
        storyOverlay.innerHTML =
          '<div class="rvts-ig-story-viewer"><div style="display: flex;flex-direction: column;align-items: center;position: absolute;top: 30px;left: 10px;z-index: 4;"> <div class="media-mini-div" style="align-items: flex-start !important;"><img class="media-mini-image"></div> <div class="rvts-story-mini-gradient" style="background: linear-gradient(rgb(226, 44, 169), rgb(228, 75, 37));"></div> <div class="rvts-story-mini-background"></div><div style=" display: flex; align-items: center; height: 45px; top: -4px; position: absolute; left: 50px; "><div style="position: relative !important;top: 0;color: white; white-space:nowrap;" class="rvts-cta-text-container"></div></div> </div> <div class="rvts-ig-story-viewer__bar"> </div> <div class="rvts-ig-story-viewer__container"><div><div class="rvts-arrow left"></div></div><div><div class="rvts-arrow right"></div></div><div class="rvts-close-button"></div><div style="display:none;"><div class="rvts-up-arrow-container"><div class="rvts-up-arrow"></div></div><div class="rvts-cta-text-container" style="font-size:16px;"></div></div><div></div></div></div>';
        var storyViewerBar = storyOverlay.querySelector(
          ".rvts-ig-story-viewer__bar"
        );
        var storyViewerContainer = storyOverlay.querySelector(
          ".rvts-ig-story-viewer__container"
        );
  
        var contentDiv = document.createElement("div");
  
        var upArrowBottom = 20;
  
        var mediaMiniGradient = storyOverlay.querySelector(
          ".rvts-story-mini-gradient"
        );
        var mediaMiniImage = storyOverlay.querySelector(".media-mini-image");
        var mediaMiniDiv = storyOverlay.querySelector(".media-mini-div");
        var mediaMiniText = mediaMiniDiv.parentElement.querySelector(
          ".rvts-cta-text-container"
        );
        var mediaMiniLeft = parseInt(mediaMiniDiv.parentElement.style.left);
        var mediaMiniTop = parseInt(mediaMiniDiv.parentElement.style.top);
  
        function scaleContent(e) {
          var innerHeight = e ? e.target.innerHeight : window.innerHeight;
          var scaleValue =
            parseFloat((innerHeight / screen.height).toFixed(1)) + 0.1;
          var scaleWidthValue =
            parseFloat((innerWidth / screen.width).toFixed(1)) + 0.1;
          if (contentDiv && contentDiv.getBoundingClientRect().width) {
            contentDiv.firstElementChild.style.transform =
              "scale(" + scaleValue + ")";
          }
          if (storyViewerContainer.children[3].getBoundingClientRect().width) {
            storyViewerContainer.children[3].style.transform =
              "scale(" + scaleValue + ")";
          }
          storyViewerContainer.children[0].style.transform =
            "scale(" + scaleValue + ")";
          storyViewerContainer.children[1].style.transform =
            "scale(" + scaleValue + ")";
          storyViewerContainer.children[2].style.transform =
            "scale(" + scaleValue + ")";
          scaleValue *= 1.5;
          if (scaleValue > 1) scaleValue = 1;
          mediaMiniDiv.parentElement.style.transform =
            "scale(" +
            scaleValue +
            ") translateX(" +
            (scaleValue - 1) * 100 +
            "%) translateY(" +
            (scaleValue - 1) * 100 +
            "%)";
        }
  
        window.addEventListener("resize", scaleContent);
  
        storyViewerContainer.children[0].addEventListener("click", function () {
          if (currentStoryBar.previousElementSibling)
            currentStoryBar.previousElementSibling.startCount();
          else {
            window.removeEventListener("resize", scaleContent);
            storyOverlay.remove();
            wBG.remove();
          }
        });
        storyViewerContainer.children[1].addEventListener("click", function () {
          if (currentStoryBar.nextElementSibling)
            currentStoryBar.nextElementSibling.startCount();
          else {
            window.removeEventListener("resize", scaleContent);
            storyOverlay.remove();
            wBG.remove();
          }
        });
        storyViewerContainer.children[2].addEventListener("click", function () {
          if (currentStoryBar && currentStoryBar.interv)
            clearInterval(currentStoryBar.interv);
          window.removeEventListener("resize", scaleContent);
          storyOverlay.remove();
          wBG.remove();
        });
        storyViewerContainer.children[3].addEventListener("click", function () {
          wBG.style.height = "100vh";
          window.freezeRvtsStoryViewer = true;
          setTimeout(function () {
            if (!isLivePreview) {
              var fetchParams =
                "cust_id=" +
                custId +
                "&popup_id=" +
                popupId +
                "&form_id=0&user_agent=" +
                navigator.userAgent +
                "&activity_type=1" +
                "&session_id=" +
                rvtsSessionId;
              if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
              if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
              fetchParams +=
                "&url=" +
                window.location.href.split("&").join(encodeURIComponent("&"));
              if (/Mobi|Android/i.test(navigator.userAgent)) {
                fetchParams += "&device=" + "1";
              } else {
                fetchParams += "&device=" + "2";
              }
              fetch(
                "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                  fetchParams
              );
              rvtsPushGaEvent(1, popupName);
            }
            if (appendUTM === true) {
              var tempURL = new URL(activeStory.ctaUrl);
              var tempLink = activeStory.ctaUrl;
              if (tempURL.search) tempLink += "&";
              else tempLink += "?";
              tempLink += "utm_source=revotas&utm_medium=sw&utm_campaign=igstory";
              window.location = tempLink;
            } else {
              window.location = activeStory.ctaUrl;
            }
          }, 1000);
        });
        var holderDiv = storyViewerContainer.children[4];
        holderDiv.style.height = "100%";
        holderDiv.style.width = "100%";
        holderDiv.style.overflow = "hidden";
        holderDiv.style.display = "flex";
        holderDiv.style.alignItems = "center";
        holderDiv.style.justifyContent = "center";
        holderDiv.style.position = "absolute";
        storyViewerContainer.addEventListener("mousedown", function () {
          window.freezeRvtsStoryViewer = true;
        });
        document.addEventListener("mouseup", function () {
          window.freezeRvtsStoryViewer = false;
        });
        storyViewerContainer.addEventListener("touchstart", function () {
          window.freezeRvtsStoryViewer = true;
        });
        document.addEventListener("touchend", function () {
          window.freezeRvtsStoryViewer = false;
        });
        var currentStoryBar = null;
        var isGroup = false;
        var groupObj = null;
        var groupPreviewUrl = storyList.preview
          ? storyList.preview
          : storyList.pictureUrl;
        if (storyList.id) {
          isGroup = true;
          groupObj = storyList;
          highlightDuration = storyList.duration;
          storyList = [...storyList.stories];
        }
  
        storyList.forEach((story) => {
          var content = story.content;
          var vAlign = story.vAlign;
          var hAlign = story.hAlign;
          var ctaText = story.ctaText;
          var ctaUrl = story.ctaUrl;
          var dur = story.duration;
          var storyBar = document.createElement("div");
          storyBar.appendChild(document.createElement("div"));
          storyBar.activateBar = function (obj) {
            contentDiv.remove();
            if (content) {
              contentDiv.innerHTML = "<div>" + content + "</div>";
              contentDiv.style.width = "100%";
              contentDiv.style.height = "100%";
              contentDiv.style.setProperty("position", "absolute", "important");
              contentDiv.style.display = "flex";
              contentDiv.style.justifyContent = hAlign;
              contentDiv.style.alignItems = vAlign;
              contentDiv.style.setProperty("z-index", 1, "important");
              storyViewerContainer.appendChild(contentDiv);
              scaleContent();
            }
            if (storyViewerContainer.querySelector("img"))
              storyViewerContainer.querySelector("img").remove();
            if (storyViewerContainer.querySelector("video"))
              storyViewerContainer.querySelector("video").remove();
            holderDiv.appendChild(obj);
            if (story.type === "image") {
              storyViewerContainer.appendChild(holderDiv);
            } else if (story.type === "video") {
              storyViewerContainer.appendChild(holderDiv);
              obj.play();
            }
          };
          storyBar.startCount = function () {
            activeStory = story;
            if (isGroup) {
              mediaMiniImage.src = groupPreviewUrl;
              mediaMiniGradient.style.background =
                "linear-gradient(180deg, " +
                groupObj.color1 +
                ", " +
                groupObj.color2 +
                ")";
            } else {
              mediaMiniImage.src = activeStory.preview
                ? activeStory.preview
                : activeStory.pictureUrl;
              mediaMiniGradient.style.background =
                "linear-gradient(180deg, " +
                activeStory.color1 +
                ", " +
                activeStory.color2 +
                ")";
            }
            if (activeStory.title) {
              mediaMiniText.textContent = activeStory.title;
            } else {
              mediaMiniText.style.setProperty("display", "none", "important");
            }
            mediaMiniDiv.style.setProperty(
              "align-items",
              activeStory.tvAlign ? activeStory.tvAlign : "center",
              "important"
            );
            storyViewerContainer.children[3].children[1].textContent =
              story.ctaText;
            if (!story.ctaUrl) {
              storyViewerContainer.children[3].style.display = "none";
            } else {
              storyViewerContainer.children[3].style.display = "";
              if (!story.ctaText) {
                storyViewerContainer.children[3].children[1].style.display =
                  "none";
              } else {
                storyViewerContainer.children[3].children[1].style.display = "";
              }
            }
  
            currentStoryBar = this;
            if (this.interv) {
              clearInterval(this.interv);
              this.interv = null;
            }
            for (
              var temp = this.previousElementSibling;
              temp;
              temp = temp.previousElementSibling
            ) {
              if (temp.interv) {
                clearInterval(temp.interv);
                temp.interv = null;
              }
              if (temp.rejecter) {
                temp.rejecter();
                temp.rejecter = null;
              }
              temp.children[0].style.transition = "none";
              temp.children[0].style.width = "100%";
              temp.children[0].offsetWidth;
              temp.children[0].style.transition = "";
            }
            for (
              var temp = this.nextElementSibling;
              temp;
              temp = temp.nextElementSibling
            ) {
              if (temp.interv) {
                clearInterval(temp.interv);
                temp.interv = null;
              }
              temp.children[0].style.transition = "none";
              temp.children[0].style.width = "0%";
              temp.children[0].offsetWidth;
              temp.children[0].style.transition = "";
            }
            var resolver = null;
            var promise = new Promise((resolve, reject) => {
              resolver = resolve;
              this.rejecter = reject;
            });
  
            if (story.type === "video") {
              var videoElement = document.createElement("video");
              var sourceElement = document.createElement("source");
              sourceElement.type = "video/mp4";
              sourceElement.src = story.url;
              if (/iPad|iPhone|iPod/.test(navigator.userAgent)) {
                videoElement.autoplay = true;
                videoElement.playsInline = true;
              }
              videoElement.appendChild(sourceElement);
              videoElement.addEventListener("loadeddata", function () {
                resolver(this);
              });
            } else if (story.type === "image") {
              var imageElement = document.createElement("img");
              imageElement.src = story.url;
              imageElement.addEventListener("load", function () {
                resolver(this);
              });
            }
            promise.then((obj) => {
              var duration = dur || highlightDuration || 2;
              if (obj && obj.duration && (!dur || dur > obj.duration))
                duration = obj.duration;
              var widthIncrement = 100 / (duration * 10);
              var width = 0;
              this.children[0].style.transition = "none";
              this.children[0].style.width = "0%";
              this.children[0].offsetWidth;
              this.children[0].style.transition = "";
              var increaseWidth = () => {
                if (window.freezeRvtsStoryViewer) {
                  if (obj && obj.duration) obj.pause();
                  return;
                } else {
                  if (obj && obj.duration && obj.paused) obj.play();
                }
                width += widthIncrement;
                this.children[0].style.width = width + "%";
                if (width >= 100) {
                  this.children[0].style.width = "100%";
                  setTimeout(() => {
                    if (this.nextElementSibling)
                      this.nextElementSibling.startCount();
                    else {
                      window.removeEventListener("resize", scaleContent);
                      storyOverlay.remove();
                      wBG.remove();
                    }
                  }, 100);
                  clearInterval(interv);
                  this.interv = null;
                  if (obj && obj.duration) obj.pause();
                }
              };
              increaseWidth();
              var interv = setInterval(increaseWidth, 100);
              this.interv = interv;
              this.activateBar(obj);
            });
          };
          storyViewerBar.appendChild(storyBar);
        });
        storyViewerBar.children[index].startCount();
        document.body.appendChild(storyOverlay);
        var storyViewer = document.querySelector(".rvts-ig-story-viewer");
        if (!isMobile) {
          function resizeStoryViewer(e) {
            var height = storyViewer.getBoundingClientRect().height;
            storyViewer.style.width = height * 0.56 + "px";
          }
          resizeStoryViewer();
          window.addEventListener("resize", resizeStoryViewer);
        }
      }
  
      function rvtsTinderReco(
        config,
        custId,
        rcpLink,
        popupId,
        popupName,
        isLivePreview
      ) {
        let idx = 0;
        let fetchArray;
        let fetchCount = 0;
        let mediaQueryMobileMax = window.matchMedia("(max-width: 415px)");
        let mediaQueryMobileMin = window.matchMedia("(min-width: 210px)");
        let hammerjs = document.createElement("script");
        hammerjs.src = "https://hammerjs.github.io/dist/hammer.min.js";
        document.head.append(hammerjs);
        let tinderRecoBaseScreen = () => {
          let tinderRecoBaseDiv = document.createElement("div");
          tinderRecoBaseDiv.style =
            "display:flex; justify-content:space-evenly; align-items:center; z-index:9999 ; bottom:10vh; right: 10vh;";
          tinderRecoBaseDiv.style["backgroundColor"] = config.tinderRecoMainColor;
          tinderRecoBaseDiv.style.borderRadius = `${config.tinderRecoBorder}px`;
          tinderRecoBaseDiv.setAttribute("id", "rvtsTinderRecoBaseDiv");
          tinderRecoBaseDiv.classList.add("rvtsTinderRecoBaseDiv");
          var tinderRecoBaseDivIconHeart = document.createElement("div");
          let heartIcon =
            decodeURIComponent(config.tinderRecoIconHeart) !== ""
              ? decodeURIComponent(config.tinderRecoIconHeart)
              : "30";
          let arrowIcon =
            decodeURIComponent(config.tinderRecoIconArrow) !== ""
              ? decodeURIComponent(config.tinderRecoIconArrow)
              : "30";
          tinderRecoBaseDivIconHeart.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="${heartIcon}px" height="${heartIcon}px"><path fill="white" d="M47.6 300.4L228.3 469.1c7.5 7 17.4 10.9 27.7 10.9s20.2-3.9 27.7-10.9L464.4 300.4c30.4-28.3 47.6-68 47.6-109.5v-5.8c0-69.9-50.5-129.5-119.4-141C347 36.5 300.6 51.4 268 84L256 96 244 84c-32.6-32.6-79-47.5-124.6-39.9C50.5 55.6 0 115.2 0 185.1v5.8c0 41.5 17.2 81.2 47.6 109.5z"/></svg>`;
          tinderRecoBaseDiv.appendChild(tinderRecoBaseDivIconHeart);
          tinderRecoBaseDivIconHeart.classList.add("rvtsTinderRecoBaseDivIcon");
          let tinderRecoBaseTextDiv = document.createElement("div");
          tinderRecoBaseTextDiv.setAttribute("id", "tinderRecoBaseTextDiv");
          tinderRecoBaseTextDiv.classList.add("tinderRecoBaseTextDiv");
          tinderRecoBaseTextDiv.style.textAlign = "center";
          let tinderRecoBaseText = document.createElement("div");
          tinderRecoBaseText.setAttribute("id", "rvtsTinderRecoBaseText ");
          tinderRecoBaseText.classList.add("rvtsTinderRecoBaseText");
          tinderRecoBaseText.innerHTML = decodeURIComponent(
            config.tinderRecoMainMessage
          );
          let tinderRecoBaseSpanText = document.createElement("div");
          tinderRecoBaseSpanText.setAttribute("id", "rvtsTinderRecoBaseSpanText");
          tinderRecoBaseSpanText.classList.add("rvtsTinderRecoBaseSpanText");
          tinderRecoBaseSpanText.innerHTML = decodeURIComponent(
            config.tinderRecoSubMessage
          );
          tinderRecoBaseTextDiv.appendChild(tinderRecoBaseText);
          tinderRecoBaseTextDiv.appendChild(tinderRecoBaseSpanText);
          tinderRecoBaseDiv.appendChild(tinderRecoBaseTextDiv);
          let tinderRecoBaseDivIconArrow = document.createElement("div");
          tinderRecoBaseDivIconArrow.classList.add("tinderRecoBaseDivIconArrow");
          tinderRecoBaseDivIconArrow.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512" width="${arrowIcon}px" height="${arrowIcon}px" transform="rotate(45)"> <path fill="white" d="M182.6 9.4c-12.5-12.5-32.8-12.5-45.3 0l-96 96c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L128 109.3V402.7L86.6 361.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3l96 96c12.5 12.5 32.8 12.5 45.3 0l96-96c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L192 402.7V109.3l41.4 41.4c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3l-96-96z"/></svg>`;
          tinderRecoBaseDiv.appendChild(tinderRecoBaseDivIconArrow);
          if (mediaQueryMobileMax.matches && mediaQueryMobileMin.matches) {
            tinderRecoBaseDiv.style[config.tinderRecoPositionLR] = "2rem";
            tinderRecoBaseDiv.style[config.tinderRecoPositionTB] = "2rem";
            tinderRecoBaseDiv.style["height"] =
              config.tinderRecoHeight != 0
                ? `${config.tinderRecoHeight}px`
                : "20vh";
            tinderRecoBaseDiv.style.width =
              config.tinderRecoWidth != 0 ? `${config.tinderRecoWidth}px` : "80%";
          } else {
            tinderRecoBaseDiv.style[config.tinderRecoPositionLR] = "5rem";
            tinderRecoBaseDiv.style[config.tinderRecoPositionTB] = "5rem";
            tinderRecoBaseDiv.style["height"] =
              config.tinderRecoHeight != 0
                ? `${config.tinderRecoHeight}px`
                : "20vh";
            tinderRecoBaseDiv.style.width =
              config.tinderRecoWidth != 0
                ? `${config.tinderRecoWidth}px`
                : "30vw";
          }
          return tinderRecoBaseDiv;
        };
        let tinderRecoCategoryScreen = () => {
          let categoriesMainDiv = document.createElement("div");
          categoriesMainDiv.style =
            "display:none; flex-direction:column; justify-content:center; align-items:center; margin:auto; width: 90%;  word-break:break-word; margin:2rem; animation: zoomIn 1s";
          categoriesMainDiv.style.borderRadius = `${config.tinderRecoCategoryBorder}px`;
          categoriesMainDiv.style.maxWidth = `${config.tinderRecoCategoryWidth}px`; // bu kısım config ile değişecek
          categoriesMainDiv.style["backgroundColor"] =
            config.tinderRecoCategoryColor;
          categoriesMainDiv.style.boxShadow = `0 0 5px ${config.tinderRecoCategoryColor}`;
          categoriesMainDiv.classList.add("rvtsCategoriesMainDiv");
          let categoryMessage = document.createElement("p");
          categoryMessage.style =
            "display:flex; justify-content:center; align-items:center; margin-top:3vmin;";
          categoryMessage.innerHTML = decodeURIComponent(
            config.tinderRecoCategoryMessage
          );
          categoryMessage.classList.add("rvtsCategoriesMessage");
          categoriesMainDiv.appendChild(categoryMessage);
          let tinderRecoNextLocal = localStorage.getItem("rvtsTinderRecoNext");
          let tinderRecoViewLocal = localStorage.getItem("rvts_recominder_view");
          // burası Maine göre düzenlenecek
          if (tinderRecoViewLocal !== null) {
            let handleFavButtonClick = (tinderRecoViewLocal) => {
              let favArry = [
                ...JSON.parse(localStorage.getItem("rvts_recominder_view")),
              ];
              categoriesMainDiv.style.display = "none";
              let favDiv = document.createElement("div");
              favDiv.style =
                "display:flex; flex-direction:column; justify-content:center; align-items:center; margin:auto; width: 90%;  word-break:break-word; margin:2rem; animation: zoomIn 1s";
              favDiv.style.maxWidth = `${config.tinderRecoFavoritesWidth}px`;
              favDiv.style.maxHeight = `${config.tinderRecoFavoritesHeight}px`;
              favDiv.style.backgroundColor = config.tinderRecoFavoritesColor;
              favDiv.style.boxShadow = `0 0 5px rgba(150, 150, 150, 1)`;
              favDiv.style.borderRadius = `${config.tinderRecoFavoritesBorder}px`;
              favDiv.classList.add("rvtsFavDiv");
              let favHeaderDiv = document.createElement("div");
              favHeaderDiv.style =
                "display:flex; flex-direction:row; justify-content:flex-start; align-items:center; width:90%; margin:10px;";
              favHeaderDiv.classList.add("rvtsFavDivHeader");
              let favBackButton = document.createElement("button");
              let favBackIconSize =
                decodeURIComponent(config.tinderRecoFavIconSize) !== ""
                  ? decodeURIComponent(config.tinderRecoFavIconSize)
                  : "30";
              let backButtonInner = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" width="${favBackIconSize}px" height="${favBackIconSize}px"><path fill="white" d="M9.4 233.4c-12.5 12.5-12.5 32.8 0 45.3l160 160c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L109.2 288 416 288c17.7 0 32-14.3 32-32s-14.3-32-32-32l-306.7 0L214.6 118.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0l-160 160z"/></svg>`;
              backButtonInner +=
                decodeURIComponent(config.tinderRecoFavButBackMessage) !==
                "<p><br></p>"
                  ? decodeURIComponent(config.tinderRecoFavButBackMessage)
                  : "<p></p>";
              favBackButton.innerHTML = backButtonInner;
              favBackButton.style = "border:none; color:white;";
              favBackButton.style.backgroundColor = config.tinderRecoBackButColor;
              favBackButton.style.borderRadius = `${config.tinderRecoFavoritesBackButtonBorder}px`;
              favBackButton.style.boxShadow = "0 0 5px rgba(58, 58, 58, 0.99)";
              favHeaderDiv.appendChild(favBackButton);
              favDiv.appendChild(favHeaderDiv);
              favBackButton.addEventListener("click", () => {
                favDiv.remove();
                categoriesMainDiv.style.display = "flex";
              });
              let favProductItemsDiv = document.createElement("div");
              favProductItemsDiv.style = "padding:10px;";
              favProductItemsDiv.classList.add("rvtsFavDivItems");
              favArry.forEach((item) => {
                let favProductItemDiv = document.createElement("div");
                favProductItemDiv.style = "display:flex;";
                favProductItemDiv.classList.add("rvtsFavDivItem");
                let favProductItemImg = document.createElement("img");
                favProductItemImg.src = item.image_link;
                favProductItemImg.style = "object-fit:contains;";
                favProductItemImg.style.width = `${config.tinderRecoFavoritesImgWidth}px`;
                favProductItemImg.style.height = `${config.tinderRecoFavoritesImgHeight}px`;
                favProductItemDiv.appendChild(favProductItemImg);
                let favProductInfo = document.createElement("div");
                favProductInfo.style = "display:flex; flex-direction:row;";
                let favProductInfoFont =
                  decodeURIComponent(config.tinderRecoFavFontSize) !== ""
                    ? decodeURIComponent(config.tinderRecoFavFontSize)
                    : "10";
                favProductInfo.style.fontSize = `${favProductInfoFont}px`;
                favProductInfo.innerHTML = `<p style="padding:10px">${item.name}</p><p style="padding:10px">${item.category_id}</p><p style="padding:10px">${item.product_sales_price}</p>`;
                favProductInfo.classList.add("rvtsFavDivItemInfo");
                favProductItemDiv.appendChild(favProductInfo);
                favProductItemsDiv.appendChild(favProductItemDiv);
                favProductItemDiv.addEventListener("click", () => {
                  window.open(item.link, "_self");
                });
              });
              favDiv.appendChild(favProductItemsDiv);
              categoryModalMain.appendChild(favDiv);
            };
            let favButton = document.createElement("button");
            favButton.innerHTML = decodeURIComponent(
              config.tinderRecoFavButMessage
            );
            favButton.style = "border:none; color: white;";
            favButton.style.backgroundColor =
              config.tinderRecoCategoryFavButtonColor;
            favButton.style.borderRadius = `${config.tinderRecoCategoryFavButBorder}px`;
            favButton.addEventListener("click", () => {
              handleFavButtonClick(tinderRecoViewLocal);
            });
            categoriesMainDiv.appendChild(favButton);
          }
  
          for (i = 0; i < 2; i++) {
            let categoriesDiv = document.createElement("div");
            categoriesDiv.classList.add("rvtsTinderRecoCategoriesDiv");
            categoriesDiv.setAttribute("id", "rvtsTinderRecoCategoriesDiv");
            categoriesDiv.style =
              "display:flex; flex-direction:row; justify-content:center; align-items:center; width:100%";
            categoriesMainDiv.appendChild(categoriesDiv);
          }
          config.categoreis.forEach((item, idx) => {
            let categoryDiv = document.createElement("div");
            categoryDiv.classList.add("rvtsTinderRecoCategoryDiv");
            categoryDiv.style =
              "display:flex; flex-direction:column; justify-content:center; align-items:center; margin:2rem;";
            var categoryImage = document.createElement("img");
            categoryImage.classList.add("rvtsCategoryImageDiv");
            categoryImage.style = "object-fit:contains;";
            categoryImage.style.borderRadius = `${config.tinderRecoCategoryImageBorder}px`;
            categoryImage.src = item.imageLink && item.imageLink;
            categoryDiv.appendChild(categoryImage);
            var categoryName = document.createElement("span");
            categoryName.style.fontSize =
              decodeURIComponent(config.tinderRecoCategoryNameFont) !== "" &&
              `${decodeURIComponent(config.tinderRecoCategoryNameFont)}px`;
            categoryName.innerText = decodeURIComponent(item.categoryNameDisplay)
              ? decodeURIComponent(item.categoryNameDisplay)
              : "";
            categoryDiv.appendChild(categoryName);
            if (idx <= 1) {
              if (
                categoriesMainDiv.children[1].id === "rvtsTinderRecoCategoriesDiv"
              ) {
                categoriesMainDiv.children[1].appendChild(categoryDiv);
              } else {
                categoriesMainDiv.children[2].appendChild(categoryDiv);
              }
            } else {
              if (
                categoriesMainDiv.children[1].id === "rvtsTinderRecoCategoriesDiv"
              ) {
                categoriesMainDiv.children[2].appendChild(categoryDiv);
              } else {
                categoriesMainDiv.children[3].appendChild(categoryDiv);
              }
            }
            if (mediaQueryMobileMax.matches && mediaQueryMobileMin.matches) {
              categoryImage.style["width"] =
                config.tinderRecoCategoryImageWidth != 0
                  ? `${config.tinderRecoCategoryImageWidth}px`
                  : "40vw";
              categoryImage.style["height"] =
                config.tinderRecoCategoryImageHeight != 0
                  ? `${config.tinderRecoCategoryImageHeight}px`
                  : "30vh";
            } else {
              categoryImage.style["width"] =
                config.tinderRecoCategoryImageWidth != 0
                  ? `${config.tinderRecoCategoryImageWidth}px`
                  : "20vw";
              categoryImage.style["height"] =
                config.tinderRecoCategoryImageHeight != 0
                  ? `${config.tinderRecoCategoryImageHeight}px`
                  : "30vh";
            }
          });
  
          if (mediaQueryMobileMax.matches && mediaQueryMobileMin.matches) {
            categoriesMainDiv.style["width"] = "90%";
          } else {
            categoriesMainDiv.style["width"] = "";
          }
          return categoriesMainDiv;
        };
        let fetchItem;
        let tinderRecoSliding = (item, temp, alertSpan) => {
          if (idx++ !== fetchArray.length) {
            fetchItem = item[0];
            let productInfo = document.createElement("div");
            productInfo.setAttribute("id", "rvtsPRoductInfoBox");
            productInfo.style =
              "display:flex; flex-direction:column-reverse; align-items:center; will-change: transform; transition: all 2s;";
            productInfo.style.color = config.tinderRecoProductTextColor;
            let productImage = document.createElement("div");
            productImage.classList.add("rvtsTinderRecoProductImage");
            productImage.style =
              "display:flex; flex-direction:column-reverse; align-items:center;";
            productImage.style.borderRadius = `${config.tinderRecoProductImageBorder}px`;
            productImage.style.backgroundRepeat = "no-repeat";
            productImage.style.backgroundPosition = "center";
            productImage.style.backgroundSize = "cover";
            productImage.style.backgroundImage = `url('${item[0].image_link}')`;
            productImage.style.margin = "2rem";
            if (mediaQueryMobileMax.matches && mediaQueryMobileMin.matches) {
              productImage.style.width =
                config.tinderRecoProductImageWidth != 0
                  ? `${config.tinderRecoProductImageWidth}px`
                  : "70vw";
              productImage.style.height =
                config.tinderRecoProductImageHeight != 0
                  ? `${config.tinderRecoProductImageHeight}px`
                  : "50vh";
            } else {
              productImage.style.width =
                config.tinderRecoProductImageWidth != 0
                  ? `${config.tinderRecoProductImageWidth}px`
                  : "30vw";
              productImage.style.height =
                config.tinderRecoProductImageHeight != 0
                  ? `${config.tinderRecoProductImageHeight}px`
                  : "50vh";
            }
            productInfo.appendChild(productImage);
            let productInfoBox = document.createElement("div");
            productInfoBox.classList.add("rvtsPrInf");
            productInfoBox.style =
              "display:flex; flex-direction:column; align-items:center;background-color: white; width:100%";
            productInfoBox.style.borderBottomLeftRadius = `${config.tinderRecoProductImageBorder}px`;
            productInfoBox.style.borderBottomRightRadius = `${config.tinderRecoProductImageBorder}px`;
            let productName = document.createElement("span");
            productName.classList.add("rvtsTinderRecoProductName");
            productName.innerText = item[0].name;
            let productPrice = document.createElement("span");
            productPrice.classList.add("rvtsTinderRecoProductPrice");
            productPrice.style =
              item[0].product_sales_price !== "" &&
              "margin:3px; text-decoration:line-through;";
            productPrice.innerText = item[0].product_price;
            let productSalesPrice = document.createElement("span");
            productSalesPrice.classList.add("rvtsTinderRecoProductSalesPrice");
            productSalesPrice.innerText = item[0].product_sales_price;
            productInfoBox.appendChild(productName);
            productInfoBox.appendChild(productPrice);
            productInfoBox.appendChild(productSalesPrice);
            productImage.appendChild(productInfoBox);
            let hammertime = new Hammer(productInfo);
            hammertime.on("pan", (event) => {
              if (event.deltaX === 0) {
                return;
              }
              if (event.center.x === 0 && event.center.y === 0) {
                return;
              }
              var xMulti = event.deltaX * 0.03;
              var yMulti = event.deltaY / 80;
              var rotate = xMulti * yMulti;
              if (event.target.classList.value === "rvtsTinderRecoProductImage") {
                event.target.style.transform =
                  "translate(" +
                  event.deltaX +
                  "px, " +
                  event.deltaY +
                  "px) rotate(" +
                  rotate +
                  "deg)";
              }
            });
            hammertime.on("panend", (event) => {
              var moveOutWidth = document.body.clientWidth;
              var keep =
                Math.abs(event.deltaX) < 80 ||
                (Math.abs(event.velocityX) < 0.9 &&
                  Math.abs(event.velocityX) > 0.0005);
              if (keep) {
                if (
                  event.target.classList.value === "rvtsTinderRecoProductImage"
                ) {
                  event.target.style.transform =
                    "translate(0px, 0px) rotate(0deg)";
                } else {
                  event.target.firstChild.style.transform =
                    "translate(0px, 0px) rotate(0deg)";
                }
              } else {
                productInfo.remove();
                var endX = Math.max(
                  Math.abs(event.velocityX) * moveOutWidth,
                  moveOutWidth
                );
                var toX = event.deltaX > 0 ? endX : -endX;
                var endY = Math.abs(event.velocityY) * moveOutWidth;
                var toY = event.deltaY > 0 ? endY : -endY;
                var xMulti = event.deltaX * 0.03;
                var yMulti = event.deltaY / 80;
                var rotate = xMulti * yMulti;
                event.target.style.transform =
                  "translate(" +
                  toX +
                  "px, " +
                  (toY + event.deltaY) +
                  "px) rotate(" +
                  rotate +
                  "deg)";
                if (event.deltaX < 0) {
                  tinderRecoSliding(fetchArray[idx], temp, alertSpan);
                } else {
                  rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
                  if (localStorage.getItem("rvts_recominder_view") !== null) {
                    let favArry = [
                      ...JSON.parse(localStorage.getItem("rvts_recominder_view")),
                    ];
                    favArry.push(fetchItem);
                    localStorage.setItem(
                      "rvts_recominder_view",
                      JSON.stringify(favArry)
                    );
                  } else {
                    let tempArr = [];
                    tempArr.push(fetchItem);
                    localStorage.setItem(
                      "rvts_recominder_view",
                      JSON.stringify(tempArr)
                    );
                  }
                  tinderRecoSliding(fetchArray[idx], temp, alertSpan);
                }
              }
            });
            temp.appendChild(productInfo);
          } else {
            tinderRecoProductFetch().then((resp) => {
              if (resp === true) {
                if (
                  decodeURIComponent(config.tinderRecoAlertMessage) !=
                  "<p><br></p>"
                ) {
                  alertSpan.style.display = "flex";
                }
                idx = 0;
                tinderRecoSliding(fetchArray[idx], temp, alertSpan);
              } else {
                idx = 0;
                categoryModalMain.style.display = "none";
                tinderRecoCatgeoryElement = tinderRecoCategoryScreen();
                categoryModalMain.appendChild(tinderRecoCatgeoryElement);
                let categoryArray = [
                  ...tinderRecoCatgeoryElement.querySelectorAll(
                    ".rvtsCategoryImageDiv"
                  ),
                ];
                categoryArray.forEach((item, idx) => {
                  item.addEventListener("click", async (e) => {
                    fetchCount = 0;
                    await tinderRecoProductFetch(
                      decodeURIComponent(config.categoreis[idx].name)
                    );
                    let leftDiv = document.createElement("div");
                    leftDiv.style.width = "35%";
                    let rightDiv = document.createElement("div");
                    rightDiv.style.width = "35%";
                    let tinderRecoProductScreenElement = tinderRecoProductScreen(
                      config.categoreis[idx]
                    );
                    categoryModalMain.appendChild(tinderRecoProductScreenElement);
                    tinderRecoCatgeoryElement.remove();
                  });
                });
                document.querySelector(".rvtsTinderRecoProductDiv").remove();
              }
            });
          }
        };
        let tinderRecoProductScreen = (categoryObj) => {
          let productDiv = document.createElement("div");
          productDiv.classList.add("rvtsTinderRecoProductDiv");
          productDiv.style =
            "display:flex; flex-direction:column; animation: zoomIn 1s";
          productDiv.style.backgroundColor = config.tinderRecoProductColor;
          productDiv.style.borderRadius = `${config.tinderRecoProductBorder}px`;
          productDiv.style.maxWidth = `${config.tinderRecoProductWidth}px`; // bu kısım değişecek config ile çekilcek
          productDiv.style.fontSize = `${decodeURIComponent(
            config.tinderRecoProductInfoFont
          )}`;
          let prCategoryName = document.createElement("label");
          prCategoryName.classList.add("rvtsProductCategoryName");
          prCategoryName.style = "padding: 1rem; width:100%";
          prCategoryName.innerText = decodeURIComponent(
            categoryObj.categoryNameDisplay
          );
          productDiv.appendChild(prCategoryName);
          let prCategoryBackButton = document.createElement("button");
          prCategoryBackButton.setAttribute("id", "rvtsProductBackButton");
          let prCategoryBackButtonSize =
            decodeURIComponent(config.tinderRecoFavIconSize) !== ""
              ? decodeURIComponent(config.tinderRecoFavIconSize)
              : "30";
          let prCategoryBackButtonInner = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" width="${prCategoryBackButtonSize}px" height="${prCategoryBackButtonSize}px"><path fill="white" d="M9.4 233.4c-12.5 12.5-12.5 32.8 0 45.3l160 160c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L109.2 288 416 288c17.7 0 32-14.3 32-32s-14.3-32-32-32l-306.7 0L214.6 118.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0l-160 160z"/></svg>`;
          prCategoryBackButtonInner +=
            decodeURIComponent(config.tinderRecoFavButBackMessage) !==
            "<p><br></p>"
              ? decodeURIComponent(config.tinderRecoFavButBackMessage)
              : "<p></p>";
          prCategoryBackButton.innerHTML = prCategoryBackButtonInner;
          prCategoryBackButton.style = "border:none; color:white;";
          prCategoryBackButton.style.width = "25%";
          prCategoryBackButton.style.backgroundColor =
            config.tinderRecoBackButColor;
          prCategoryBackButton.style.borderRadius = `${config.tinderRecoFavoritesBackButtonBorder}px`;
          productDiv.appendChild(prCategoryBackButton);
          prCategoryBackButton.addEventListener("click", () => {
            handleProductBackButtonClick();
          });
          let alertSpan = document.createElement("span");
          alertSpan.style.display = "none";
          alertSpan.setAttribute("id", "rvtsAlertSpan");
          alertSpan.innerHTML =
            typeof decodeURIComponent(config.tinderRecoAlertMessage) !==
              "<p>undefined</p>" ||
            decodeURIComponent(config.tinderRecoAlertMessage) !== "<p><br></p>"
              ? decodeURIComponent(config.tinderRecoAlertMessage)
              : "";
          productDiv.appendChild(alertSpan);
          let temp = document.createElement("div");
          temp.style.width = "100%";
  
          productDiv.appendChild(temp);
          let buttonDiv = document.createElement("div");
          buttonDiv.style = "display:flex; justify-content:center;";
          buttonDiv.style.margin = "2vmin";
          let nextButton = document.createElement("button");
          let viewButton = document.createElement("button");
          tinderRecoSliding(fetchArray[idx], temp, alertSpan);
  
          viewButton.setAttribute("id", "rvtsTinderRecoViewButton");
          viewButton.addEventListener("click", () => {
            let styleTemp = temp.querySelector("#rvtsPRoductInfoBox");
            styleTemp.style.transform = `translate(${
              document.body.clientWidth * 1.5
            }px, -100px) rotate(-30deg)`;
            setTimeout(() => {
              temp.querySelector("#rvtsPRoductInfoBox").remove();
              tinderRecoSliding(fetchArray[idx], temp, alertSpan);
            }, 1000);
            rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
            if (localStorage.getItem("rvts_recominder_view") !== null) {
              let favArry = [
                ...JSON.parse(localStorage.getItem("rvts_recominder_view")),
              ];
              favArry.push(fetchItem);
              localStorage.setItem(
                "rvts_recominder_view",
                JSON.stringify(favArry)
              );
            } else {
              let tempArr = [];
              tempArr.push(fetchItem);
              localStorage.setItem(
                "rvts_recominder_view",
                JSON.stringify(tempArr)
              );
            }
          });
          nextButton.addEventListener("click", () => {
            let styleTemp = temp.querySelector("#rvtsPRoductInfoBox");
            styleTemp.style.transition = "2s";
            styleTemp.style.transform = `translate(-${
              document.body.clientWidth * 1.5
            }px, -100px) rotate(30deg)`;
            setTimeout(() => {
              temp.querySelector("#rvtsPRoductInfoBox").remove();
              tinderRecoSliding(fetchArray[idx], temp, alertSpan);
            }, 1000);
          });
          buttonDiv.appendChild(nextButton);
          buttonDiv.appendChild(viewButton);
          productDiv.appendChild(buttonDiv);
          nextButton.classList.add("rvtsTinderRecoNextButton");
          viewButton.classList.add("rvtsTinderRecoViewButton");
          let productButIconSize =
            decodeURIComponent(config.tinderRecoProductButIconSize) !== ""
              ? decodeURIComponent(config.tinderRecoProductButIconSize)
              : "30";
          var nextButtonHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 320 512" width="${productButIconSize}px" height="${productButIconSize}px"><path fill="white" d="M310.6 150.6c12.5-12.5 12.5-32.8 0-45.3s-32.8-12.5-45.3 0L160 210.7 54.6 105.4c-12.5-12.5-32.8-12.5-45.3 0s-12.5 32.8 0 45.3L114.7 256 9.4 361.4c-12.5 12.5-12.5 32.8 0 45.3s32.8 12.5 45.3 0L160 301.3 265.4 406.6c12.5 12.5 32.8 12.5 45.3 0s12.5-32.8 0-45.3L205.3 256 310.6 150.6z"/></svg>`;
          nextButtonHTML +=
            decodeURIComponent(config.tinderRecoNextButtonMessage) !==
            "<p><br></p>"
              ? decodeURIComponent(config.tinderRecoNextButtonMessage)
              : "<p></p>";
          nextButton.innerHTML = nextButtonHTML;
          var viewButtonHtml = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" width="${productButIconSize}px" height="${productButIconSize}px"><path  fill="white" d="M47.6 300.4L228.3 469.1c7.5 7 17.4 10.9 27.7 10.9s20.2-3.9 27.7-10.9L464.4 300.4c30.4-28.3 47.6-68 47.6-109.5v-5.8c0-69.9-50.5-129.5-119.4-141C347 36.5 300.6 51.4 268 84L256 96 244 84c-32.6-32.6-79-47.5-124.6-39.9C50.5 55.6 0 115.2 0 185.1v5.8c0 41.5 17.2 81.2 47.6 109.5z"/></svg>`;
          viewButtonHtml +=
            decodeURIComponent(config.tinderRecoViewButtonMessage) !==
            "<p><br></p>"
              ? decodeURIComponent(config.tinderRecoViewButtonMessage)
              : "<p></p>";
          viewButton.innerHTML = viewButtonHtml;
          nextButton.style =
            "margin:3px; border:none; text-align: center; color: white; padding:0 1vh 0 1vh;";
          viewButton.style =
            "margin:3px; border:none; text-align: center; color: white; padding:0 1vh 0 1vh;";
          nextButton.style.backgroundColor =
            config.tinderRecoProductNextButtonColor;
          nextButton.style.borderRadius = `${config.tinderRecoProductButtonBorder}px`;
          viewButton.style.backgroundColor =
            config.tinderRecoProductViewButtonColor;
          viewButton.style.borderRadius = `${config.tinderRecoProductButtonBorder}px`;
  
          return productDiv;
        };
        let tinderRecoProductFetch = async (name) => {
          if (fetchCount !== 2) {
            fetchCount++;
            let categoryName = { categoryId: name };
            var product = await fetch(
              `https://${rcpLink}/rrcp/imc/recommendation/get_recommendation.jsp?cust_id=${custId}&type=50&limit=10`,
              {
                method: "POST",
                body: JSON.stringify(categoryName),
              }
            ).then((resp) => resp.json());
            fetchArray = [...product];
            return true;
          } else {
            return false;
          }
        };
        var categoryModalMain = document.createElement("div");
        categoryModalMain.setAttribute("id", "rvtsTinderCategoryModal");
        categoryModalMain.classList.add("categoryModalMain");
        categoryModalMain.style =
          "display: none; position: fixed;  z-index: 9999; left:0px; top:0px; width: 100%; height: 100%; overflow: auto;  background-color: rgb(0,0,0); align-items:center; justify-content:center;/* Fallback color */background-color: rgba(0,0,0,0.4); /* Black w/ opacity */";
        let tinderRecoBaseScreenElement = tinderRecoBaseScreen();
        let tinderRecoCatgeoryElement = tinderRecoCategoryScreen();
        let categoryArray = [
          ...tinderRecoCatgeoryElement.querySelectorAll(".rvtsCategoryImageDiv"),
        ];
        tinderRecoBaseScreenElement.addEventListener("click", () => {
          categoryModalMain.style.display = "flex";
          tinderRecoCatgeoryElement.style.display = "flex";
        });
        categoryArray.forEach((item, idx) => {
          item.addEventListener("click", async (e) => {
            await tinderRecoProductFetch(
              decodeURIComponent(config.categoreis[idx].name)
            );
            let leftDiv = document.createElement("div");
            leftDiv.style.width = "35%";
            let rightDiv = document.createElement("div");
            rightDiv.style.width = "35%";
            let tinderRecoProductScreenElement = tinderRecoProductScreen(
              config.categoreis[idx]
            );
            categoryModalMain.appendChild(tinderRecoProductScreenElement);
            tinderRecoCatgeoryElement.remove();
          });
        });
        let handleProductBackButtonClick = () => {
          tinderRecoCatgeoryElement = tinderRecoCategoryScreen();
          categoryModalMain.appendChild(tinderRecoCatgeoryElement);
          tinderRecoCatgeoryElement.style.display = "flex";
          document.querySelector(".rvtsTinderRecoProductDiv").remove();
          let categoryArray = [
            ...tinderRecoCatgeoryElement.querySelectorAll(
              ".rvtsCategoryImageDiv"
            ),
          ];
          categoryArray.forEach((item, idx) => {
            item.addEventListener("click", async (e) => {
              await tinderRecoProductFetch(
                decodeURIComponent(config.categoreis[idx].name)
              );
              let leftDiv = document.createElement("div");
              leftDiv.style.width = "35%";
              let rightDiv = document.createElement("div");
              rightDiv.style.width = "35%";
              let tinderRecoProductScreenElement = tinderRecoProductScreen(
                config.categoreis[idx],
                tinderRecoCatgeoryElement
              );
              categoryModalMain.appendChild(tinderRecoProductScreenElement);
              tinderRecoCatgeoryElement.remove();
            });
          });
        };
        categoryModalMain.appendChild(tinderRecoCatgeoryElement);
  
        document.body.appendChild(categoryModalMain);
        let position = decodeURIComponent(config.tinderRecoInsertPosition);
        let querySelector = decodeURIComponent(config.tinderRecoQuerySelector);
        if (querySelector != "") {
          if (position === "replace") {
            document
              .querySelector(querySelector)
              .parentNode.replaceChild(
                tinderRecoBaseScreenElement,
                document.querySelector(querySelector)
              );
          } else {
            document
              .querySelector(querySelector)
              .insertAdjacentElement(position, tinderRecoBaseScreenElement);
          }
        } else {
          tinderRecoBaseScreenElement.style.position = "fixed";
          document.body.appendChild(tinderRecoBaseScreenElement);
        }
        window.onclick = function (event) {
          if (event.target == categoryModalMain) {
            categoryModalMain.style.display = "none";
          }
        };
        if (config.tinderRecorCss) {
          var style = document.createElement("style");
          style.innerHTML = decodeURIComponent(config.tinderRecorCss);
          document.head.appendChild(style);
        }
        rvtsPushSmartWidgetActivity(null, popupId, popupName, 0);
      }
      function rvtsUpsellProBar(
        config,
        custId,
        popupId,
        popupName,
        isLivePreview
      ) {
        // goalAmount objeden alınacak
        //defaultMessage,shipProMessage,succesProMessage objeden geliyor
        //hesaplanacak sepet değeri internet sitesinden alınacak
        //width 0% başlayacak sepet değeri değiştikçe barwidth artacak
  
        //Ek fonksiyonlar
        const cartTotalCalc = () => {
          if (
            typeof RvstData != "undefined" ||
            typeof rvtsCart != "undefined" ||
            typeof RvtsBasketCart != "undefined"
          ) {
            if (
              typeof RvstData !== "undefined" &&
              typeof RvstData.oAmt != "undefined" &&
              Number(RvstData.oAmt) !== 0
            ) {
              let orderAmount = Number(RvstData.oAmt).toFixed(2);
              return orderAmount;
            }
            if (
              typeof rvtsCart != "undefined" &&
              typeof rvtsCart.data.PRICE_GENERAL != "undefined" &&
              Number(rvtsCart.data.PRICE_GENERAL) !== 0
            ) {
              let orderAmount = Number(rvtsCart.data.PRICE_GENERAL).toFixed(2);
              return orderAmount;
            }
            if (
              typeof RvtsBasketCart != "undefined" &&
              typeof RvtsBasketCart.total != "undefined" &&
              Number(RvtsBasketCart.total) !== 0
            ) {
              let orderAmount = Number(RvtsBasketCart.total).toFixed(2);
              return orderAmount;
            } else {
              return false;
            }
          }
        };
        const message = () => {
          //messajlar witdh e göre değişecek
          //Bar mesajlar Şu şekilde sepette ürün yoksa default mesaj çıkacak
          //sepette ürün varsa ve bar dolmadıysa ship mesaj çıkacak
          //sepet dolduysa tutar karşılandıysa succes mesaj çıkacak
          if (cartTotal === false && newwidth === 0) {
            //default mesaj
            if (
              defaultMessage.includes(goalAmountStr) ||
              defaultMessage.includes(difAmountStr) ||
              defaultMessage.includes(cartTotalStr)
            ) {
              let message = defaultMessage.includes(goalAmountStr)
                ? defaultMessage.replaceAll(
                    goalAmountStr,
                    goalAmount ? goalAmount.toString() : "0"
                  )
                : defaultMessage;
              message = message.includes(difAmountStr)
                ? message.replaceAll(
                    difAmountStr,
                    diffAmount !== 0 ? diffAmount.toFixed(2).toString() : "0"
                  )
                : message;
              message = message.includes(cartTotalStr)
                ? message.replaceAll(
                    cartTotalStr,
                    cartTotal !== false ? cartTotal.toString() : "0"
                  )
                : message;
              return message;
            } else {
              return defaultMessage;
            }
          } else {
            if (newwidth < 100) {
              if (
                shipProMessage.includes(goalAmountStr) ||
                shipProMessage.includes(difAmountStr) ||
                shipProMessage.includes(cartTotalStr)
              ) {
                let message = shipProMessage.includes(goalAmountStr)
                  ? shipProMessage.replaceAll(
                      goalAmountStr,
                      goalAmount ? goalAmount.toString() : "0"
                    )
                  : shipProMessage;
                message = message.includes(difAmountStr)
                  ? message.replaceAll(
                      difAmountStr,
                      diffAmount !== 0 ? diffAmount.toFixed(2).toString() : "0"
                    )
                  : message;
                message = message.includes(cartTotalStr)
                  ? message.replaceAll(
                      cartTotalStr,
                      cartTotal !== false ? cartTotal.toString() : "0"
                    )
                  : message;
                return message;
              } else {
                return shipProMessage;
              }
              //shipmesaj
            } else if (newwidth == 100) {
              if (
                succesProMessage.includes(goalAmountStr) ||
                succesProMessage.includes(difAmountStr) ||
                succesProMessage.includes(cartTotalStr)
              ) {
                let message = succesProMessage.includes(goalAmountStr)
                  ? succesProMessage.replaceAll(
                      goalAmountStr,
                      goalAmount ? goalAmount.toString() : "0"
                    )
                  : succesProMessage;
                message = message.includes(difAmountStr)
                  ? message.replaceAll(
                      difAmountStr,
                      diffAmount !== 0 ? diffAmount.toFixed(2).toString() : "0"
                    )
                  : message;
                message = message.includes(cartTotalStr)
                  ? message.replaceAll(
                      cartTotalStr,
                      cartTotal !== false ? cartTotal.toString() : "0"
                    )
                  : message;
                return message;
              } else {
                return succesProMessage;
              }
              //succesmesaj
            }
          }
        };
        var goalAmount = Number(config.goalAmount).toFixed(2);
        var defaultMessage = decodeURIComponent(config.defaultMessage);
        var shipProMessage = decodeURIComponent(config.shipProMessage);
        var succesProMessage = decodeURIComponent(config.succesProMessage);
        var goalAmountStr = "[GOAL_AMOUNT]";
        var difAmountStr = "[DIFF_AMOUNT]";
        var cartTotalStr = "[TOTAL_CART]";
        var cartTotal = cartTotalCalc();
        var diffAmount = cartTotal !== false ? goalAmount - cartTotal : 0;
        diffAmount = diffAmount > 0 ? diffAmount : 0;
        //width degerinin hesaplanması
        var newwidth = (cartTotal / goalAmount) * 100;
        newwidth = newwidth >= 100 ? (newwidth = 100) : newwidth;
        let width = `${newwidth}%`;
        var progressBar = document.createElement("div");
        var progress = document.createElement("div");
        var bar = document.createElement("div");
        var barMessage = document.createElement("p");
        //
        progressBar.style =
          "display:flex; justify-content:center;align-items:center; width:100%; flex-direction:column;";
        progressBar.style["color"] = config.barTextColor;
        progressBar.classList.add("rvtsProgressBar");
        progressBar.setAttribute("id", "rvtsProgressBar");
        progress.style =
          "position:relative;overflow:hidden;transition:all 0.5s;will-change:transform";
        progress.style["width"] = config.upsellProBarWidth
          ? config.upsellProBarWidth.toString() + "%"
          : "30%";
        progress.style["height"] = config.upsellProBarHeight
          ? config.upsellProBarHeight.toString() + "px"
          : "10px";
        progress.style["backgroundColor"] = config.barBgColor;
        progress.style["borderRadius"] = config.upsellProBarBrRadius
          ? config.upsellProBarBrRadius.toString() + "px"
          : "20px";
        progress.style.boxShadow = "0 0 5px " + config.barBsColor;
        progress.classList.add("rvtsProgress");
        progress.setAttribute("id", "rvtsProgress");
        bar.style =
          "position:absolute;height:100%;top:0;bottom:0;border-radius:inherit;display:flex;justify-content:center;align-items:center;";
        bar.style["width"] = width; // Burası Çokomelliii
        bar.style["backgroundColor"] = config.barColor;
        bar.classList.add("rvtsBar");
        bar.setAttribute("id", "rvtsBar");
        //Element stilleri
        progress.appendChild(bar);
        barMessage.classList.add("rvtsBarMessage");
        barMessage.setAttribute("id", "rvtsBarMessage");
        var barMessageText = message();
        barMessage.innerHTML = barMessageText;
        progressBar.appendChild(barMessage);
        progressBar.appendChild(progress);
  
        let position = decodeURIComponent(config.upsellProBarInsertPosition);
        let querySelector = decodeURIComponent(config.upsellProBarQuerySelector);
        if (querySelector) {
          if (position === "replace") {
            document
              .querySelector(querySelector)
              .parentNode.replaceChild(
                progressBar,
                document.querySelector(querySelector)
              );
          } else {
            document
              .querySelector(querySelector)
              .insertAdjacentElement(position, progressBar);
          }
        } else {
          document.body.appendChild(progressBar);
        }
        var quilLink = document.createElement("link");
        quilLink.rel = "stylesheet";
        quilLink.href = "https://cdn.quilljs.com/1.3.6/quill.snow.css";
        document.head.append(quilLink);
        if (config.upsellProBarCss) {
          var style = document.createElement("style");
          style.innerHTML = decodeURIComponent(config.upsellProBarCss);
          document.head.appendChild(style);
        }
        rvtsPushSmartWidgetActivity(null, popupId, popupName, 0);
      }
      function rvts_start_time(data) {
        var alreadyStarted = false;
        var arr = [];
        if (data) {
          arr = data.split(",");
  
          document.getElementById("secondButton").innerText = arr[1];
  
          if (alreadyStarted) return;
          var timeLeft = arr[0];
          timeLeft *= 60;
          var cname = "discount_timer";
          var cookie;
          if ((cookie = getCookie("discount_timer"))) {
            console.log(cookie, "cookie");
            var startDate = new Date(cookie);
            var now = new Date();
            timeLeft -= Math.floor((now.getTime() - startDate.getTime()) / 2000);
          } else {
            setCookie(cname, new Date(), 1, window.location.hostname);
          }
          if (timeLeft === 0) {
            document.getElementById("timeleft").innerText = arr[2];
          } else {
            var timer = setInterval(
              (timerFunc = function () {
                if (timeLeft <= 0) clearInterval(timer);
                var timeElement = document.getElementById("timeleft");
                var seconds = timeLeft % 60;
                if ((seconds + "").length === 1) seconds = "0" + seconds;
                var minutes = (timeLeft - seconds) / 60;
                if ((minutes + "").length === 1) minutes = "0" + minutes;
                timeElement.innerText = minutes + ":" + seconds;
                timeLeft--;
                if (timeLeft <= 0) {
                  localStorage.removeItem("discount_timer");
                  document.getElementById("timeleft").innerText = arr[2];
                }
              }),
              1000
            );
            timerFunc();
          }
  
          alreadyStarted = true;
        }
      }
  
      function rvts_kopyala(data) {
        if (data) {
          var newData = data.split(",");
          //document.getElementById("secondButton").innerText = newData[0];
  
          document.getElementById("secondButton").style.backgroundColor =
            newData[1] + newData[2] + newData[3] + newData[4];
          document.getElementById("secondButton").setAttribute("disabled", "");
          var textArea = document.createElement("textarea");
          textArea.id = "textArea";
  
          textArea.value = newData[5];
          document.getElementById("secondButton").appendChild(textArea);
          textArea.select();
  
          try {
            var successful = document.execCommand("copy");
            var msg = successful ? "successful" : "unsuccessful";
  
            //	  console.log('Copying text command was ' + msg);
          } catch (err) {
            //	 console.log('Oops, unable to copy');
          }
          document.getElementById("secondButton").removeChild(textArea);
        }
      }
  
      function rvtsDrawerDiscount(config, popupId, popupName, custId, isPreview) {
        var drawer_main_div = document.createElement("div");
        drawer_main_div.id = "drawer-discount-main-div";
        drawer_main_div.className = "smart-widget-container-div1";
        drawer_main_div.style.setProperty(
          "width",
          config.drawerDiscountTableWidth + "px",
          "important"
        );
        drawer_main_div.style =
          "background-color: white;position: fixed !important;display: block;align-items: center;justify-content: center;transition:all 1s ease;top: calc(50% - 96px);background-color: rgba(54, 161, 239, 0); z-index: 2147483647 !important;";
        var firstTable = document.createElement("table"); //for main table
        firstTable.id = "drawer-discount-main-table";
        firstTable.style =
          "border:none !important;background:transparent !important";
        firstTable.style.setProperty(
          "width",
          config.drawerDiscountTableWidth + "px",
          "important"
        );
        firstTable.setAttribute("cellpadding", "0");
        firstTable.setAttribute("cellspacing", "0");
        firstTable.setAttribute("align", "center");
  
        drawer_main_div.appendChild(firstTable);
  
        var firstTr = document.createElement("tr");
        firstTr.id = "drawer-discount-main-tr";
        firstTr.style =
          "display:flex !important;padding:0px !important;margin-bottom:16px !important;";
        firstTr.style.setProperty(
          "height",
          config.drawerDiscountHeight + "px",
          "important"
        );
        firstTable.appendChild(firstTr);
  
        let tempHeight = parseInt(config.drawerDiscountHeight);
  
        var firstTd = document.createElement("td"); // for %10 indirim kodu
        firstTd.id = "drawer-discount-left-td";
        firstTd.style =
          "padding:0;border:none !important;height:180px;display:flex;justify-content:center;align-items:center;";
        firstTd.style.setProperty(
          "background-color",
          config.titleColor,
          "important"
        );
        firstTd.style.setProperty("color", config.titleTextColor, "important");
        firstTd.style.setProperty("border", "none", "important");
        firstTd.style.setProperty(
          "width",
          config.drawerDiscountLeftBarWidth + "px",
          "important"
        );
        firstTd.style.setProperty(
          "height",
          `${tempHeight - 1}` + "px",
          "important"
        );
        firstTr.appendChild(firstTd);
  
        var tableSvg = document.createElement("svg");
        tableSvg.style.setProperty("color", config.titleTextColor, "important");
        tableSvg.setAttribute("width", "50");
        tableSvg.setAttribute("height", "174");
        tableSvg.style = "height:100%;";
        tableSvg.id = "tableSvg";
  
        var svgText = document.createElement("text");
        svgText.id = "drawer-discount-info-text";
        //height:200px;width:170px;display:inline-block;overflow:hidden !important;white-space:nowrap;text-overflow:ellipsis;
        svgText.style =
          "overflow:hidden;white-space:nowrap;text-overflow:ellipsis;font-size:16px;font-family:Poppins !important;font-weight:300;text-align:center;margin:0px auto;writing-mode:vertical-rl;transform:rotate(180deg);height:80%;";
        svgText.setAttribute("x", "28");
        svgText.setAttribute("transform", "rotate(-90,28,160)");
        svgText.setAttribute("y", "160");
        svgText.setAttribute("fill", "white");
        svgText.setAttribute("color", config.titleTextColor, "important");
        svgText.innerText = decodeURIComponent(config.infoText);
        //tableSvg.appendChild();
        firstTd.appendChild(svgText);
  
        let newWidth = `${config.drawerDiscountTableWidth}px`;
        let newWidth1 = `${parseInt(config.drawerDiscountLeftBarWidth) - 2}px`;
  
        let newHeight = `${config.drawerDiscountHeight}px`;
        let newHeight1 = `${parseInt(config.drawerDiscountHeight) - 30}px`;
        var secondTd = document.createElement("td");
        secondTd.style =
          "padding:8px;width:90%;border:none !important;display:flex;justify-content:center;align-items:center;";
        secondTd.style.setProperty("border", "none", "important");
        secondTd.style.setProperty(
          "height",
          config.drawerDiscountHeight + "px",
          "important"
        );
        secondTd.id = "drawer-discount-right-td";
  
        var secondTable = document.createElement("table");
        secondTable.style =
          "padding: 20px 0px;border-radius:5px;border:none !important;background:none !important";
        secondTable.style.setProperty(
          "height",
          config.drawerDiscountHeight + "px",
          "important"
        );
        secondTable.setAttribute("align", "center");
        secondTable.setAttribute("cellpadding", "0");
        secondTable.setAttribute("cellspacing", "0");
  
        secondTable.id = "drawer-discount-body-table";
  
        firstTr.appendChild(secondTd);
        secondTd.appendChild(secondTable);
  
        var firstTbody = document.createElement("tbody");
        firstTbody.id = "drawer-discount-tbody";
        firstTbody.style =
          "display:flex;flex-direction:column;justify-content:space-between !important;align-items:center;height:100%;";
        secondTable.appendChild(firstTbody);
  
        var secondTr = document.createElement("tr");
        secondTr.id = "drawer-discount-time-container";
        firstTbody.appendChild(secondTr);
  
        var thirdTd = document.createElement("td"); // for time counter or time is up
        thirdTd.style.setProperty("border", "none", "important");
        thirdTd.style =
          "font-family: Calibri,Arial;font-size: 30px;font-weight: bold;padding:0;border:none !important;color:#000 !important;";
        thirdTd.setAttribute("align", "center");
        thirdTd.id = "drawer-discount-time-bar";
  
        secondTr.appendChild(thirdTd);
  
        var firstSpan = document.createElement("span");
        firstSpan.id = "timeleft";
        var newTime = config.timeValue;
        newTime = newTime.toString();
  
        firstSpan.innerText = "0" + newTime + ":00";
        if (newTime < 1) {
          firstSpan.innerText = "00:30";
        } else if (newTime > 9) {
          firstSpan.innerText = newTime + ":00";
        } else {
          firstSpan.innerText = "0" + newTime + ":00";
        }
        thirdTd.appendChild(firstSpan);
        var secondButton = document.createElement("button");
        secondButton.id = "copylink";
        secondButton.className = "btn btn-flat copybtn";
        secondButton.id = "secondButton";
  
        secondButton.setAttribute(
          "onclick",
          `rvts_start_time('${decodeURIComponent(
            config.timeValue
          )},${decodeURIComponent(config.buttonTextTimeUp)},${decodeURIComponent(
            config.timeupWarning
          )}')`
        );
        secondButton.style =
          "padding: 3px 5px !important; font-size: 17px;background-color: #ff6600; height: 38px !important; border-radius: 0px !important; line-height: 12px !important;border:none !important;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;text-align: center !important;";
        secondButton.style.setProperty(
          "background-color",
          config.buttonColor,
          "important"
        );
        secondButton.style.setProperty(
          "color",
          config.titleTextColor,
          "important"
        );
        secondButton.style.setProperty(
          "width",
          config.drawerDiscountButtonWidth + "px",
          "important"
        );
        secondButton.addEventListener("click", () => {
          rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
        });
        var thirdTr = document.createElement("tr"); //for discount decs
        thirdTr.id = "drawer-discount-description-container";
        thirdTr.style = "display:contents !important";
        firstTbody.appendChild(thirdTr);
        firstTbody.setAttribute(
          "onclick",
          `rvts_kopyala('${decodeURIComponent(config.buttonTextTimeUp)},${
            config.buttonColor
          },${config.discountCode}')`
        );
  
        var fourthTd = document.createElement("td");
        fourthTd.id = "drawer-discount-description-text";
        fourthTd.style =
          "font-family: Calibri,Arial;font-size: 16px;font-weight: bold; color:#666 !important;padding:0;border:none !important;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;";
  
        fourthTd.setAttribute("align", "center");
  
        fourthTd.innerText = decodeURIComponent(config.descText);
        thirdTr.appendChild(fourthTd);
  
        var fourthTr = document.createElement("tr"); //for discount code
        fourthTr.id = "drawer-discount-code-container";
        fourthTr.style = "display:flex;justify-content:center;width:100%";
        var fifthTd = document.createElement("td");
        fifthTd.id = "drawer-discount-code";
        fifthTd.style =
          "padding-bottom: 5px; padding-top: 10px;font-family: Calibri,Arial;font-size: 24px; color:#666 !important;padding:0;width:100%";
        fifthTd.style.setProperty(
          "border",
          `3px dashed ${config.discountBorderColor}`,
          "important"
        );
  
        fifthTd.setAttribute("align", "center");
  
        var discountCodeDiv = document.createElement("div");
        discountCodeDiv.id = "copylink2";
        discountCodeDiv.innerText = decodeURIComponent(config.discountCode);
  
        fifthTd.appendChild(discountCodeDiv);
        fourthTr.appendChild(fifthTd);
        firstTbody.appendChild(fourthTr);
  
        var fifthTr = document.createElement("tr"); //for copy button before start
        fifthTr.id = "drawer-discount-copyButton-container";
        var sixthTd = document.createElement("td");
  
        sixthTd.style = "padding: 7px;border:none !important;";
        sixthTd.style.setProperty("border", "none", "important");
        sixthTd.id = "drawer-discount-copy-button";
        sixthTd.setAttribute("align", "center");
  
        if ((cookie = getCookie("discount_timer"))) {
          secondButton.innerText = decodeURIComponent(config.buttonTextTimeUp);
          document.getElementById("secondButton").style.backgroundColor =
            "#ff6600";
        }
  
        secondButton.innerText = decodeURIComponent(config.buttonTextBeforeStart);
  
        sixthTd.appendChild(secondButton);
        fifthTr.appendChild(sixthTd);
        firstTbody.appendChild(fifthTr);
  
        config.showDuration = "1000ms";
        config.closeDuration = "1000ms";
        config.height = newHeight;
        config.width = newWidth;
        config.previewSize = newWidth1;
        config.backgroundColor = "white";
        config.overlayColor = "";
        config.startPosition = "right center";
        config.vAlign = "center";
        config.hAlign = "center";
        config.html = drawer_main_div.innerHTML;
        config.iframeLink = "";
        config.overlayClick = "close";
        config.overlayLock = "false";
        config.drawerStartState = "closed";
        config.cssLinks = "";
  
        var style = document.createElement("style");
        style.innerHTML = decodeURIComponent(config.drawerDiscountCss);
        document.head.appendChild(style);
  
        var popup = null;
        popup = drawerPopup(config, popupId, popupName);
        rvtsPushSmartWidgetActivity(null, popupId, popupName, 0);
        return popup;
      }
      function rvtsExitIntent(config) {
        var scrollAvailable = config.shiftingCheck;
        var oldTitle = document.title;
        var tabFocus = 0;
        var title = decodeURIComponent(config.exitIntentText);
  
        if (title.length !== "" && title.length !== null) {
          window.onblur = function () {
            document.title = title;
  
            if (scrollAvailable == 1) {
              var position = 0;
  
              tabFocus = 0;
  
              function scrolltitle() {
                if (tabFocus == 1) {
                  return;
                }
  
                document.title =
                  title.substring(position, title.length) +
                  title.substring(0, position);
                position++;
                if (position > title.length) position = 0;
                window.setTimeout(scrolltitle, 200);
              }
  
              scrolltitle();
            } else {
              scrollAvailable == 0
                ? (document.title = title)
                : (document.title = oldTitle);
            }
          };
  
          window.onfocus = function () {
            tabFocus = 1;
  
            if (tabFocus == 1) {
              document.title = oldTitle;
            }
          };
        } else {
          document.title = oldTitle;
        }
      }
  
      async function rvtsPopup(
        params,
        isPreview,
        custId,
        popupId,
        popupName,
        formId,
        rcpLink,
        isLivePreview
      ) {
        console.log(params, "params");
        console.log(params.type, "params.type");
  
        if (!window["rvtsSmartWidgetList"]) window["rvtsSmartWidgetList"] = {};
        window["rvtsSmartWidgetList"][popupId] = {};
        window["rvtsSmartWidgetList"][popupId].widgetType = params.type;
        window["rvtsSmartWidgetList"][popupId].custId = custId;
        window["rvtsSmartWidgetList"][popupId].popupId = popupId;
        window["rvtsSmartWidgetList"][popupId].formId = formId;
        window["rvtsSmartWidgetList"][popupId].params = params;
        var popup;
        var notification;
        if (params.type === "sticky") {
          popup = stickyPopup(params, popupId, popupName);
        } else if (params.type === "sliding") {
          popup = slidingPopup(params, popupId, null, popupName, formId);
        } else if (params.type === "fading") {
          popup = fadingPopup(params, popupId, null, popupName, formId);
        } else if (params.type === "drawer") {
          popup = drawerPopup(params, popupId, popupName);
        } else if (params.type === "productAlert") {
          try {
            if (params.scriptCode) window.eval(params.scriptCode);
          } catch (err) {
            console.warn(params.scriptCode);
            console.warn("There was an error with the above smartwidget script");
            console.warn("Smartwidget ID: " + popupId);
            console.warn(err);
          }
          rvtsProductAlert(params, popupId, popupName, custId);
        } else if (params.type === "socialProof") {
          var initialDelay = params.socialProofSettings.initialDelay;
          var showInLoop = params.socialProofSettings.showInLoop;
          var loopInterval = params.socialProofSettings.loopInterval;
          try {
            if (!isPreview && params.scriptCode) window.eval(params.scriptCode);
          } catch (err) {
            console.warn(params.scriptCode);
            console.warn("There was an error with the above smartwidget script");
            console.warn("Smartwidget ID: " + popupId);
            console.warn(err);
          }
          popup = await rvtsSocialProof(
            params,
            popupId,
            popupName,
            custId,
            rcpLink,
            isPreview
          );
          if (!popup) return;
          if (!isPreview) {
            setTimeout(function () {
              if (showInLoop == 1) {
                var loopFunction = () => {
                  setTimeout(function () {
                    if (!isLivePreview)
                      popup.show(false, custId, popupId, formId, loopFunction);
                    else popup.show(true, null, null, null, loopFunction);
                  }, parseDuration(loopInterval));
                };
                if (!isLivePreview)
                  popup.show(false, custId, popupId, formId, loopFunction);
                else popup.show(true, null, null, null, loopFunction);
              } else {
                if (!isLivePreview) popup.show(false, custId, popupId, formId);
                else popup.show(true);
              }
            }, parseDuration(initialDelay));
          }
          return popup;
        } else if (params.type === "exitIntent") {
          var exitIntentSettings = params.exitIntentSettings;
          rvtsExitIntent(exitIntentSettings);
  
          // bugfix 06.09.24 - EXIT INTENT WIDGET add script code feature didn't work properly at revotas panel in EXIT INTENT WIDGET "content tab".
          try {
            if (params.scriptCode)
              eval(
                "(function(){" +
                  params.scriptCode +
                  "}).call(exitIntentSettings);"
              );
          } catch (err) {
            console.warn(params.scriptCode);
            console.warn(
              "Exit intent widget content tab script code error, please check the script code"
            );
            console.warn("Smartwidget ID: " + popupId);
            console.warn(err);
          }
        } else if (params.type === "recentlyView") {
          function runRvtsRecently() {
            var recentlyData = params;
            popup = rvtsRecentlyView(
              recentlyData,
              custId,
              popupId,
              popupName,
              isPreview
            );
            try {
              if (params.scriptCode)
                eval("(function(){" + params.scriptCode + "}).call(popup);");
            } catch (err) {
              console.warn(params.scriptCode);
              console.warn(
                "There was an error with the above smartwidget script"
              );
              console.warn("Smartwidget ID: " + popupId);
              console.warn(err);
            }
            if (!popup) return;
          }
          //runRvtsRecently(recentlyData,custId, popupId, popupName, isPreview)
          if (document.readyState !== "loading") runRvtsRecently();
          else document.addEventListener("DOMContentLoaded", runRvtsRecently);
          //localStorage.getItem("rvts_product_history_array") && rvtsRecentlyView(params, custId, popupId, popupName, isLivePreview);
        }
  
        // 18.04.2025 - blockedWebpush first time not working issue fixed.
        else if (params.type === "blockedWebpush") {
          console.log("[SmartWidget] blockedWebpush tipi tespit edildi:", params);
          function runRvtsBlockedWebpush() {
            console.log("[SmartWidget] runRvtsBlockedWebpush çağrıldı");
  
            var blockedWebpush = params;
  
            popup = rvtsBlockedWebpush(
              blockedWebpush,
              custId,
              popupId,
              popupName,
              isPreview
            );
            try {
              if (params.scriptCode)
                eval("(function(){" + params.scriptCode + "}).call(popup);");
            } catch (err) {
              console.warn(params.scriptCode);
              console.warn(
                "There was an error with the above smartwidget script"
              );
              console.warn("Smartwidget ID: " + popupId);
              console.warn(err);
            }
            if (!popup) return;
          }
  
          if (localStorage.getItem("rvts_webpush_domain")) {
            console.log("[SmartWidget] Immediate run branch");
            runRvtsBlockedWebpush();
          } else {
            console.log("[SmartWidget] Listener branch kuruluyor");
            window.addEventListener("revotas:domainSaved", runRvtsBlockedWebpush);
          }
  
          // —————— fallback: listener veya immediate kaçırıldıysa
          setTimeout(() => {
            if (localStorage.getItem("rvts_webpush_domain")) {
              console.log("[SmartWidget] Fallback run");
  
              runRvtsBlockedWebpush();
            }
          }, 500);
        } else if (params.type === "igStory") {
          var igStorySettings = params.igStorySettings;
          igStorySettings.storyList = JSON.parse(
            decodeURIComponent(igStorySettings.storyList)
          );
          function runRvtsStory() {
            rvtsStoryContainerLive(
              igStorySettings.storyList,
              igStorySettings.querySelector,
              igStorySettings.insertPosition,
              isLivePreview,
              popupId,
              popupName,
              custId,
              igStorySettings.appendUTM
            ).then((mainStoryDiv) => {
              try {
                if (params.scriptCode)
                  eval(
                    "(function(){" + params.scriptCode + "}).call(mainStoryDiv);"
                  );
              } catch (err) {
                console.warn(params.scriptCode);
                console.warn(
                  "There was an error with the above smartwidget script"
                );
                console.warn("Smartwidget ID: " + popupId);
                console.warn(err);
              }
            });
          }
          if (document.readyState !== "loading") runRvtsStory();
          else document.addEventListener("DOMContentLoaded", runRvtsStory);
        } else if (params.type === "imageTagging") {
          function runRvtsImageTagging() {
            rvtsImageTagging(
              params.imageTaggingSettings,
              custId,
              popupId,
              popupName,
              isLivePreview
            ).then((mainDiv) => {
              try {
                if (params.scriptCode)
                  eval("(function(){" + params.scriptCode + "}).call(mainDiv);");
              } catch (err) {
                console.warn(params.scriptCode);
                console.warn(
                  "There was an error with the above smartwidget script"
                );
                console.warn("Smartwidget ID: " + popupId);
                console.warn(err);
              }
            });
          }
          if (document.readyState !== "loading") runRvtsImageTagging();
          else document.addEventListener("DOMContentLoaded", runRvtsImageTagging);
        } else if (params.type === "upsellProBar") {
          function runrvtsUpsellProBar() {
            var upsellProBarSettings = params.upsellProBarSettings;
            var upsellProBarElement = rvtsUpsellProBar(
              upsellProBarSettings,
              custId,
              popupId,
              popupName,
              isLivePreview
            );
            try {
              if (params.scriptCode)
                eval(
                  "(function(){" +
                    params.scriptCode +
                    "}).call(upsellProBarElement);"
                );
            } catch (err) {
              console.warn(params.scriptCode);
              console.warn(
                "There was an error with the above smartwidget script"
              );
              console.warn("Smartwidget ID: " + popupId);
              console.warn(err);
            }
          }
          if (document.readyState !== "loading") runrvtsUpsellProBar();
          else document.addEventListener("DOMContentLoaded", runrvtsUpsellProBar);
        } else if (params.type === "drawerDiscount") {
          function runrvtsDrawerDiscount() {
            var drawerDiscountSetting = params.drawerDiscountSettings;
  
            popup = rvtsDrawerDiscount(
              drawerDiscountSetting,
              popupId,
              popupName,
              custId,
              isPreview
            );
            try {
              if (params.scriptCode)
                eval("(function(){" + params.scriptCode + "}).call(popup);");
            } catch (err) {
              console.warn(params.scriptCode);
              console.warn(
                "There was an error with the above smartwidget script"
              );
              console.warn("Smartwidget ID: " + popupId);
              console.warn(err);
            }
            if (!popup) return;
          }
          if (document.readyState !== "loading") runrvtsDrawerDiscount();
          else
            document.addEventListener("DOMContentLoaded", runrvtsDrawerDiscount);
        } else if (params.type === "tinderReco") {
          function runrvtsTinderReco() {
            var tinderRecoSettings = params.tinderRecoSettings;
            var tinderRecoElement = rvtsTinderReco(
              tinderRecoSettings,
              custId,
              rcpLink,
              popupId,
              popupName,
              isLivePreview
            );
            try {
              if (params.scriptCode)
                eval(
                  "(function(){" +
                    params.scriptCode +
                    "}).call(tinderRecoElement);"
                );
            } catch (err) {
              console.warn(params.scriptCode);
              console.warn(
                "There was an error with the above smartwidget script"
              );
              console.warn("Smartwidget ID: " + popupId);
              console.warn(err);
            }
          }
          if (document.readyState !== "loading") runrvtsTinderReco();
          else document.addEventListener("DOMContentLoaded", runrvtsTinderReco);
        } else if (params.type === "pages") {
          function runRvtsPages() {
            var elementList = rvtsPages(
              params.pagesSettings,
              custId,
              popupId,
              popupName,
              isLivePreview
            );
            try {
              if (params.scriptCode)
                eval(
                  "(function(){" + params.scriptCode + "}).call(elementList);"
                );
            } catch (err) {
              console.warn(params.scriptCode);
              console.warn(
                "There was an error with the above smartwidget script"
              );
              console.warn("Smartwidget ID: " + popupId);
              console.warn(err);
            }
          }
          if (document.readyState !== "loading") runRvtsPages();
          else document.addEventListener("DOMContentLoaded", runRvtsPages);
        } else if (params.type === "backInStock") {
          function runBackInStock() {
            var backInStockButton = rvtsBackInStock(
              params.backInStockSettings,
              custId,
              popupId,
              formId,
              popupName,
              isLivePreview
            );
            if (!backInStockButton) return;
            try {
              if (params.scriptCode)
                eval(
                  "(function(){" +
                    params.scriptCode +
                    "}).call(backInStockButton);"
                );
            } catch (err) {
              console.warn(params.scriptCode);
              console.warn(
                "There was an error with the above smartwidget script"
              );
              console.warn("Smartwidget ID: " + popupId);
              console.warn(err);
            }
          }
          if (document.readyState !== "loading") runBackInStock();
          else document.addEventListener("DOMContentLoaded", runBackInStock);
        } else if (params.type === "notificationCenter") {
          function runNotificationCenter() {
            notificationCenter(
              params.notificationCenterSettings,
              custId,
              popupId,
              popupName,
              isLivePreview
            ).then((notification) => {
              try {
                if (params.scriptCode)
                  eval(
                    "(function(){" + params.scriptCode + "}).call(notification);"
                  );
              } catch (err) {
                console.warn(params.scriptCode);
                console.warn(
                  "There was an error with the above smartwidget script"
                );
                console.warn("Smartwidget ID: " + popupId);
                console.warn(err);
              }
            });
          }
          if (document.readyState !== "loading") runNotificationCenter();
          else
            document.addEventListener("DOMContentLoaded", runNotificationCenter);
        } else if (params.type === "countDown") {
          var timer = CountDown(
            params.countDownSettings,
            false,
            custId,
            popupId,
            popupName
          );
          try {
            if (params.scriptCode)
              eval("(function(){" + params.scriptCode + "}).call(timer);");
          } catch (err) {
            console.warn(params.scriptCode);
            console.warn("There was an error with the above smartwidget script");
            console.warn("Smartwidget ID: " + popupId);
            console.warn(err);
          }
        } else if (params.type === "whatsapp") {
          rvtsWhatsapp(params, custId, popupId, popupName, isLivePreview);
        } else if (params.type === "spinWheel") {
          rvtsSpinWheel(params, custId, popupId, popupName);
        } else if (params.type === "dealOfDay") {
          rvtsDealOfDay(params, popupId, popupName);
  
          try {
            if (params.scriptCode)
              eval("(function(){" + params.scriptCode + "}).call();");
          } catch (err) {
            console.warn(params.scriptCode);
            console.warn("There was an error with the above smartwidget script");
            console.warn("Smartwidget ID: " + popupId);
            console.warn(err);
          }
        } else if (params.type === "dealsDiscovery") {
          discovery = dealsDiscovery(
            params.dealsDiscoverySettings,
            popupId,
            popupName
          );
          try {
            if (params.scriptCode)
              eval("(function(){" + params.scriptCode + "}).call(discovery);");
          } catch (err) {
            console.warn(params.scriptCode);
            console.warn("There was an error with the above smartwidget script");
            console.warn("Smartwidget ID: " + popupId);
            console.warn(err);
          }
        } else if (params.type === "abTest") {
          var currentTest = localStorage.getItem(popupId + "_current_test");
          if (!currentTest) {
            currentTest = await fetch(
              "https://f.revotas.com/frm/smartwidgets/get_smartwidget_abtest.jsp?cust_id=" +
                custId +
                "&tester_id=" +
                popupId
            )
              .then((resp) => resp.json())
              .then((resp) => resp.currentWidgetId);
            localStorage.setItem(popupId + "_current_test", currentTest);
          }
          var currentPopup = JSON.parse(
            sessionStorage.getItem("sw_session_config")
          ).filter((e) => e.popupId === currentTest)[0];
          let scheduleSatisfied = false;
          let obj = currentPopup.object;
  
          if (obj.schedule) {
            if (obj.schedule === "scheduleDateRange") {
              let range = obj.scheduleRange.split("-");
              let now = new Date();
              let start = new Date(range[0]);
              let end = new Date(range[1]);
              if (now >= start && now <= end) {
                //Run widget
                scheduleSatisfied = true;
              }
            } else if (obj.schedule === "scheduleDaily") {
              let range = obj.scheduleDailyTimeRange.split("-");
              let startTime = range[0].trim().split(":");
              let endTime = range[1].trim().split(":");
              let now = new Date();
              let start = new Date();
              let end = new Date();
              start.setHours(...startTime);
              end.setHours(...endTime);
              if (now >= start && now <= end) {
                //Run widget
                scheduleSatisfied = true;
              }
            } else if (obj.schedule === "scheduleWeekly") {
              let weekDays = obj.scheduleWeeklyDay;
              let range = obj.scheduleWeeklyTimeRange.split("-");
              let startTime = range[0].trim().split(":");
              let endTime = range[1].trim().split(":");
              let now = new Date();
              let start = new Date();
              let end = new Date();
              start.setHours(...startTime);
              end.setHours(...endTime);
              if (
                now >= start &&
                now <= end &&
                weekDays.includes(now.getDay().toString())
              ) {
                //Run widget
                scheduleSatisfied = true;
              }
            } else if (obj.schedule === "noSchedule") {
              scheduleSatisfied = true;
            }
          } else {
            scheduleSatisfied = true;
          }
  
          let nonBlocking = obj.nonBlocking;
          let formId = currentPopup.formId;
          let widgetId = currentPopup.popupId;
          let popupName = currentPopup.popupName;
          let rcpLink = currentPopup.rcp_link;
          let registerPage = currentPopup.registerPage;
          let cartPage = currentPopup.cartPage;
          let orderPage = currentPopup.orderPage;
          if (scheduleSatisfied) {
            executeGroup(
              obj.conditionConfig,
              {
                registerPage: registerPage,
                cartPage: cartPage,
                orderPage: orderPage,
              },
              widgetId,
              currentPopup
            ).then(function (result) {
              if (result) {
                if (obj.html) obj.html = decodeURIComponent(obj.html);
                if (obj.thankYouHtml)
                  obj.thankYouHtml = decodeURIComponent(obj.thankYouHtml);
                if (obj.scriptCode)
                  obj.scriptCode = decodeURIComponent(obj.scriptCode);
                rvtsPopup(
                  obj,
                  false,
                  custId,
                  widgetId,
                  popupName,
                  formId,
                  rcpLink,
                  false
                );
              }
            });
          }
  
          try {
            if (params.scriptCode)
              eval("(function(){" + params.scriptCode + "}).call();");
          } catch (err) {
            console.warn(params.scriptCode);
            console.warn("There was an error with the above smartwidget script");
            console.warn("Smartwidget ID: " + popupId);
            console.warn(err);
          }
        }
        if (popup) {
          window["rvtsSmartWidgetList"][popupId] = {
            ...popup,
            ...window["rvtsSmartWidgetList"][popupId],
          };
        }
  
        if (!isPreview) {
          if (params.trigger === "scroll") {
            var scrollEvent = function () {
              if (getScrollPercent() >= params.scrollPercentage) {
                if (popup) {
                  if (!isLivePreview) popup.show(false, custId, popupId, formId);
                  else popup.show(true);
                }
                document.removeEventListener("scroll", scrollEvent);
                try {
                  if (params.scriptCode)
                    eval("(function(){" + params.scriptCode + "}).call(popup);");
                } catch (err) {
                  console.warn(params.scriptCode);
                  console.warn(
                    "There was an error with the above smartwidget script"
                  );
                  console.warn("Smartwidget ID: " + popupId);
                  console.warn(err);
                }
              }
            };
            document.addEventListener("scroll", scrollEvent);
          } else if (params.trigger === "mouseLeave") {
            var alreadyTriggered = false;
            var leaveEvent = function () {
              if (alreadyTriggered) return;
              alreadyTriggered = true;
              if (popup) {
                if (!isLivePreview) popup.show(false, custId, popupId, formId);
                else popup.show(true);
              }
              try {
                if (params.scriptCode)
                  eval("(function(){" + params.scriptCode + "}).call(popup);");
              } catch (err) {
                console.warn(params.scriptCode);
                console.warn(
                  "There was an error with the above smartwidget script"
                );
                console.warn("Smartwidget ID: " + popupId);
                console.warn(err);
              }
            };
  
            if (params.exitIntentType) {
              if (params.exitIntentType.includes("mouseExit")) {
                setTimeout(function () {
                  document.addEventListener("mouseleave", leaveEvent, {
                    once: true,
                  });
                }, 2000);
              }
  
              if (params.exitIntentType.includes("idleExit")) {
                var delay = params.idleDelay;
                var timeoutEvent = function () {
                  leaveEvent();
                  document.removeEventListener("mousemove", delayEvent);
                  document.removeEventListener("scroll", delayEvent);
                  document.removeEventListener("keypress", delayEvent);
                  document.removeEventListener("mousedown", delayEvent);
                  //document.removeEventListener('touchstart', delayEvent);
                };
                var timeout = setTimeout(timeoutEvent, delay);
                var delayEvent = function () {
                  if (timeout) clearTimeout(timeout);
                  timeout = setTimeout(timeoutEvent, delay);
                };
                document.addEventListener("mousemove", delayEvent);
                document.addEventListener("scroll", delayEvent);
                document.addEventListener("keypress", delayEvent);
                document.addEventListener("mousedown", delayEvent);
                // document.addEventListener('touchstart', delayEvent);
              }
  
              if (params.exitIntentType.includes("backButton")) {
                function swBackButton() {
                  window.history.pushState("swBackPressed", null, null);
                  window.history.pushState("dummy", null, null);
                  window.addEventListener(
                    "popstate",
                    function (event) {
                      if (event.state === "swBackPressed") {
                        leaveEvent();
                      }
                    },
                    { once: true }
                  );
                }
                if (document.readyState !== "loading") swBackButton();
                else document.addEventListener("DOMContentLoaded", swBackButton);
              }
  
              if (params.exitIntentType.includes("quickScrollUp")) {
                (function () {
                  var startPercent = 0;
                  var endPercent = 0;
                  var startTime = null;
                  var endTime = null;
  
                  var scrollStart = false;
                  var scrollEnd = false;
  
                  var scrollEndTimeout = null;
  
                  var scrollFunc = function () {
                    if (!scrollStart) {
                      scrollStart = true;
                      startPercent = getScrollPercent();
                      startTime = new Date();
                    }
                    if (scrollEndTimeout) {
                      clearTimeout(scrollEndTimeout);
                    }
                    scrollEndTimeout = setTimeout(function () {
                      scrollEnd = true;
                      scrollStart = false;
                      endPercent = getScrollPercent();
                      endTime = new Date();
                      var scrollSpeed = Math.round(
                        (startPercent - endPercent) /
                          ((endTime - startTime) / 1000)
                      );
                      if (scrollSpeed >= 80) {
                        document.removeEventListener("scroll", scrollFunc);
                        leaveEvent();
                      }
                    }, 100);
                  };
                  document.addEventListener("scroll", scrollFunc);
                })();
              }
  
              if (params.exitIntentType.includes("tabSwitch")) {
                window.addEventListener("blur", leaveEvent, { once: true });
              }
            } else {
              setTimeout(function () {
                document.addEventListener("mouseleave", leaveEvent, {
                  once: true,
                });
              }, 2000);
            }
          } else if (params.trigger === "afterLoad") {
            var run = function () {
              function runAfterLoad() {
                if (popup) {
                  if (!isLivePreview) popup.show(false, custId, popupId, formId);
                  else popup.show(true);
                }
                try {
                  if (params.scriptCode)
                    eval("(function(){" + params.scriptCode + "}).call(popup);");
                } catch (err) {
                  console.warn(params.scriptCode);
                  console.warn(
                    "There was an error with the above smartwidget script"
                  );
                  console.warn("Smartwidget ID: " + popupId);
                  console.warn(err);
                }
              }
              if (parseDuration(params.delay) == 0) runAfterLoad();
              else setTimeout(runAfterLoad, parseDuration(params.delay));
            };
            if (document.readyState !== "loading") run();
            else document.addEventListener("DOMContentLoaded", run);
          }
        }
        return popup;
      }
  
      async function rvtsImageTagging(
        config,
        custId,
        popupId,
        popupName,
        isLivePreview
      ) {
        var isMobile = __smartWidgetConditionFunctions__.deviceType("mobile");
  
        var tagForms = [];
  
        var isInViewPort = function (right, bottom) {
          return {
            bottom:
              (window.innerHeight || document.documentElement.clientHeight) -
              bottom,
            right:
              (window.innerWidth || document.documentElement.clientWidth) - right,
          };
        };
  
        var inImageView = function (right, bottom) {
          return {
            right: img.getBoundingClientRect().right - right,
            bottom: img.getBoundingClientRect().bottom - bottom,
          };
        };
  
        function saveImageTagActivity(actType) {
          if (!isLivePreview) {
            var fetchParams =
              "cust_id=" +
              custId +
              "&popup_id=" +
              popupId +
              "&form_id=0&user_agent=" +
              navigator.userAgent +
              "&activity_type=" +
              actType +
              "&session_id=" +
              rvtsSessionId;
            if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
            fetchParams +=
              "&url=" +
              window.location.href.split("&").join(encodeURIComponent("&"));
            if (/Mobi|Android/i.test(navigator.userAgent)) {
              fetchParams += "&device=" + "1";
            } else {
              fetchParams += "&device=" + "2";
            }
            fetch(
              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                fetchParams
            );
            if (actType == 1) saveSwSource(popupId);
            rvtsPushGaEvent(actType, popupName);
          }
        }
  
        function generateTagForm(tag, left, top, mark) {
          var tagDiv = document.createElement("div");
          if (tag.url) {
            tagDiv.addEventListener("click", function (e) {
              e.preventDefault();
              window.open(decodeURIComponent(tag.url), "_blank");
              this.style.setProperty("display", "none", "important");
              saveImageTagActivity(1);
            });
          }
          tagDiv.classList.add("_" + popupId + "_rvts_image_tag_form");
          if (config.startWithTagsOpen != 1)
            tagDiv.style.setProperty("display", "none", "important");
          tagDiv.style.setProperty("left", left + "px", "important");
          tagDiv.style.setProperty("top", top + "px", "important");
          tagDiv.innerHTML =
            '<div style="' +
            (tag.image ? "" : "display:none;") +
            '" class="_' +
            popupId +
            '_rvts_image_tag_img" style="cursor: pointer;"><img src="' +
            decodeURIComponent(tag.image) +
            '"></div><div class="_' +
            popupId +
            '_rvts_image_tag_fields"><div class="_' +
            popupId +
            '_rvts_image_tag_name" style="cursor: pointer;' +
            (tag.name ? "" : "display:none;") +
            '">' +
            decodeURIComponent(tag.name) +
            '</div><div class="_' +
            popupId +
            "_rvts_image_tag_price" +
            (tag.sales_price ? " rvts_org_price" : "") +
            '" style="cursor: pointer;' +
            (tag.price ? "" : "display:none;") +
            '">' +
            decodeURIComponent(tag.price) +
            '</div><div class="_' +
            popupId +
            '_rvts_image_tag_sales_price" style="cursor: pointer;' +
            (tag.sales_price ? "" : "display:none;") +
            '">' +
            decodeURIComponent(tag.sales_price) +
            '</div><button class="_' +
            popupId +
            '_rvts_image_tag_button" style="cursor: pointer;' +
            (config.imageTagUrlText && tag.url ? "" : "display:none;") +
            '">' +
            decodeURIComponent(config.imageTagUrlText) +
            "</button></div>";
  
          var tagDivCopy = tagDiv.cloneNode(true);
          tagDivCopy.style.display = "";
          tagDivCopy.style.visibility = "hidden";
          tagDivCopy.style.setProperty("left", "0", "important");
          tagDivCopy.style.setProperty("top", "0", "important");
          document.body.appendChild(tagDivCopy);
  
          rvtsWaitFor((resolve, reject) => {
            var bound = tagDivCopy.getBoundingClientRect();
            if (bound.width > 0 && bound.height > 0) {
              resolve({
                width: bound.width,
                height: bound.height,
              });
            }
          }).then((obj) => {
            tagDiv.props = obj;
            tagDivCopy.remove();
          });
  
          tagDiv.show = function () {
            var boundLeft = mark.getBoundingClientRect().left;
            var boundTop = mark.getBoundingClientRect().top;
            var left = null;
            var top = null;
            if (isMobile) {
              left =
                parseInt(mark.style.left) +
                parseInt(mark.getBoundingClientRect().width);
              top =
                parseInt(mark.style.top) +
                parseInt(mark.getBoundingClientRect().height);
            } else {
              left =
                parseInt(mark.style.left) +
                parseInt(mark.getBoundingClientRect().width / 2);
              top =
                parseInt(mark.style.top) +
                parseInt(mark.getBoundingClientRect().height / 2);
            }
            var isIn = isInViewPort(
              boundLeft + tagDiv.props.width,
              boundTop + tagDiv.props.height
            );
            var isInImg = inImageView(
              boundLeft + tagDiv.props.width,
              boundTop + tagDiv.props.height
            );
            if (isIn.right >= 0 && isInImg.right >= 0) {
              tagDiv.style.setProperty("left", left + "px", "important");
            } else {
              var currentLeft =
                left + (isIn.right > isInImg.right ? isInImg.right : isIn.right);
              var minLeft = left - tagDiv.props.width;
              if (minLeft > currentLeft) currentLeft = minLeft;
              if (isMobile) {
                tagDiv.style.setProperty(
                  "left",
                  currentLeft -
                    parseInt(mark.getBoundingClientRect().width) +
                    "px",
                  "important"
                );
              } else {
                tagDiv.style.setProperty(
                  "left",
                  currentLeft -
                    parseInt(mark.getBoundingClientRect().width / 2) +
                    "px",
                  "important"
                );
              }
            }
            if (isIn.bottom >= 0 && isInImg.bottom >= 0) {
              tagDiv.style.setProperty("top", top + "px", "important");
            } else {
              var currentBottom =
                top +
                (isIn.bottom > isInImg.bottom ? isInImg.bottom : isIn.bottom);
              var minBottom = top - tagDiv.props.height;
              if (minBottom > currentBottom) currentBottom = minBottom;
              if (isMobile) {
                tagDiv.style.setProperty(
                  "top",
                  currentBottom -
                    parseInt(mark.getBoundingClientRect().height) +
                    "px",
                  "important"
                );
              } else {
                tagDiv.style.setProperty(
                  "top",
                  currentBottom -
                    parseInt(mark.getBoundingClientRect().height / 2) +
                    "px",
                  "important"
                );
              }
            }
            tagDiv.style.display = "";
          };
          tagForms.push(tagDiv);
          return tagDiv;
        }
  
        var selectedTag = null;
  
        var style = document.createElement("style");
        style.innerHTML = "";
        document.head.appendChild(style);
  
        var style2 = document.createElement("style");
        style2.innerHTML = decodeURIComponent(config.css);
        if (isMobile) {
          style2.innerHTML += ".rvts_image_tag_img{display:none !important;}";
        }
        style2.innerHTML = style2.innerHTML
          .split("rvts_image_tag")
          .join("_" + popupId + "_rvts_image_tag");
        document.head.appendChild(style2);
  
        var mainDiv = document.createElement("div");
        mainDiv.style.setProperty("position", "relative", "important");
  
        var img = document.createElement("img");
        img.src = decodeURIComponent(config.imageLink);
        img.style.height =
          config.imageHeight > 0 ? config.imageHeight + "px" : "100%";
        img.style.width =
          config.imageWidth > 0 ? config.imageWidth + "px" : "100%";
        mainDiv.appendChild(img);
  
        var position = config.imageInsertPosition;
        var querySelector = decodeURIComponent(config.imageQuerySelector);
  
        await rvtsWaitFor((resolve, reject) => {
          if (document.querySelector(querySelector)) resolve();
        });
  
        if (position === "replace") {
          document
            .querySelector(querySelector)
            .parentElement.replaceChild(
              mainDiv,
              document.querySelector(querySelector)
            );
        } else {
          document
            .querySelector(querySelector)
            .insertAdjacentElement(position, mainDiv);
        }
  
        var marker = document.createElement("div");
        marker.style.borderRadius = "50%";
        marker.style.position = "absolute";
        marker.style.cursor = "pointer";
  
        var mainDivResolver = null;
        var mainDivPromise = new Promise((resolve, reject) => {
          mainDivResolver = resolve;
        });
  
        var imageResolver = null;
        var imageLoaded = new Promise((resolve, reject) => {
          imageResolver = resolve;
        });
  
        img.addEventListener("load", function () {
          imageResolver(true);
        });
  
        img.addEventListener("click", function () {
          var shownCount = tagForms.filter(
            (form) => form.style.display == ""
          ).length;
          tagForms.forEach((form) => {
            if (shownCount > 0) {
              form.style.setProperty("display", "none", "important");
            } else {
              form.show();
            }
          });
        });
  
        imageLoaded.then(() => {
          var pulseStartRadius = config.pulseStartRadius;
          var pulseEndRadius = config.pulseEndRadius;
          var pulseSpeed = config.pulseSpeed;
          var markColor = config.markColor;
          var pulseColor = config.pulseColor;
          if (pulseSpeed > 0) {
            style.innerHTML =
              "@keyframes rvtsPulse_" +
              popupId +
              " { 0%,100% { box-shadow: 0px 0px " +
              pulseStartRadius +
              "px " +
              pulseStartRadius +
              "px " +
              pulseColor +
              "; } 30% { box-shadow: 0px 0px " +
              pulseEndRadius +
              "px " +
              pulseEndRadius +
              "px " +
              pulseColor +
              "; } }";
          } else {
            style.innerHTML = "";
          }
  
          rvtsWaitFor(function (resolve, reject) {
            if (
              img.getBoundingClientRect().width > 0 &&
              img.getBoundingClientRect().height > 0
            )
              resolve(true);
          }).then(() => {
            var rect = img.getBoundingClientRect();
            var sizeRef = rect.width > rect.height ? rect.width : rect.height;
            config.tagList.forEach((tag) => {
              var closeTimeout = null;
              var mark = marker.cloneNode(true);
              mark.style.animation =
                "rvtsPulse_" + popupId + " " + pulseSpeed + "ms infinite";
              var top = (rect.height * tag.verticalOffset) / 100;
              var left = (rect.width * tag.horizontalOffset) / 100;
              var tagForm = generateTagForm(tag, left, top, mark);
              mainDiv.appendChild(tagForm);
              mark.style.boxShadow =
                "0px 0px " +
                pulseStartRadius +
                "px " +
                pulseStartRadius +
                "px " +
                pulseColor;
              mark.style.backgroundColor = markColor;
              mark.style.width =
                config.imageTagMarkSize > 0
                  ? config.imageTagMarkSize + "px"
                  : sizeRef * 0.04 + "px";
              mark.style.height =
                config.imageTagMarkSize > 0
                  ? config.imageTagMarkSize + "px"
                  : sizeRef * 0.04 + "px";
              mark.style.top =
                config.imageTagMarkSize > 0
                  ? top - config.imageTagMarkSize / 2 + "px"
                  : top - (sizeRef * 0.04) / 2 + "px";
              mark.style.left =
                config.imageTagMarkSize > 0
                  ? left - config.imageTagMarkSize / 2 + "px"
                  : left - (sizeRef * 0.04) / 2 + "px";
              window.addEventListener("resize", function () {
                var rect = img.getBoundingClientRect();
                var top = (rect.height * tag.verticalOffset) / 100;
                var left = (rect.width * tag.horizontalOffset) / 100;
                mark.style.width =
                  config.imageTagMarkSize > 0
                    ? config.imageTagMarkSize + "px"
                    : sizeRef * 0.04 + "px";
                mark.style.height =
                  config.imageTagMarkSize > 0
                    ? config.imageTagMarkSize + "px"
                    : sizeRef * 0.04 + "px";
                mark.style.top =
                  config.imageTagMarkSize > 0
                    ? top - config.imageTagMarkSize / 2 + "px"
                    : top - (sizeRef * 0.04) / 2 + "px";
                mark.style.left =
                  config.imageTagMarkSize > 0
                    ? left - config.imageTagMarkSize / 2 + "px"
                    : left - (sizeRef * 0.04) / 2 + "px";
                if (tagForm.style.display == "") tagForm.show();
              });
              window.addEventListener("scroll", function () {
                if (tagForm.style.display == "") tagForm.show();
              });
              if (!isMobile) {
                mark.addEventListener("click", function (e) {
                  e.preventDefault();
                  window.open(decodeURIComponent(tag.url), "_blank");
                  saveImageTagActivity(1);
                  tagForm.style.setProperty("display", "none", "important");
                });
              } else {
                mark.addEventListener("click", function (e) {
                  e.preventDefault();
                  if (tagForm.style.display == "") {
                    tagForm.style.setProperty("display", "none", "important");
                  } else {
                    tagForm.show();
                  }
                });
              }
              tagForm.addEventListener("mouseenter", function () {
                if (closeTimeout) {
                  clearTimeout(closeTimeout);
                  closeTimeout = null;
                }
              });
              tagForm.addEventListener("mouseleave", function () {
                if (!closeTimeout) {
                  closeTimeout = setTimeout(function () {
                    tagForm.style.setProperty("display", "none", "important");
                    closeTimeout = null;
                  }, 250);
                }
              });
              if (!isMobile) {
                mark.addEventListener("mouseenter", function () {
                  if (closeTimeout) {
                    clearTimeout(closeTimeout);
                    closeTimeout = null;
                  }
                  tagForm.show();
                });
              }
              mark.addEventListener("mouseleave", function () {
                if (!closeTimeout) {
                  closeTimeout = setTimeout(function () {
                    tagForm.style.setProperty("display", "none", "important");
                    closeTimeout = null;
                  }, 250);
                }
              });
  
              mainDiv.appendChild(mark);
            });
            mainDivResolver(mainDiv);
            saveImageTagActivity(0);
          });
        });
  
        return mainDivPromise;
      }
  
      function rvtsBackInStock(
        config,
        custId,
        popupId,
        formId,
        popupName,
        isLivePreview
      ) {
        var productId =
          typeof rvtsSWCurrentProduct !== "undefined"
            ? rvtsSWCurrentProduct.p_id
            : null;
        if (productId == null) return;
        var button = document.createElement("button");
        button.style.setProperty(
          "height",
          config.buttonHeight + "px",
          "important"
        );
        button.style.setProperty("width", config.buttonWidth + "px", "important");
        var borderColor = config.buttonBorderColor;
        var borderWidth = config.buttonBorderWidth;
        button.style.setProperty(
          "border",
          borderWidth + "px solid " + borderColor,
          "important"
        );
        button.style.setProperty(
          "border-radius",
          config.buttonBorderRadius + "px",
          "important"
        );
        button.style.setProperty("color", config.buttonTextColor, "important");
        button.style.setProperty(
          "background-color",
          config.buttonBGColor,
          "important"
        );
        button.style.setProperty(
          "font-size",
          config.buttonFontSize + "px",
          "important"
        );
        button.textContent = decodeURIComponent(config.buttonText);
        var selectedElement = document.querySelector(config.querySelector);
        var insertPosition = config.insertPosition;
  
        var formVarName = `rvtsBackInStockForm_${popupId}`;
        var optInDivVarName = `optInDiv_${popupId}`;
  
        var html = `<style>
          form[name=Subscribe]>button {
              width: 100px;
              height: 30px;
              background-color: white;
              color: black;
              margin-top: 20px;
          }
          form[name=Subscribe] {
              display: flex;
              flex-direction: column;
              justify-content: center;
              align-items: center;
          }
          @keyframes optInWarning {
            from {border: 1px solid black}
            to {border:1 px solid transparent}
          }
      </style>
      <form action="https://revoform.revotas.com/frm/sv/FormProcessor" method="Post" name="Subscribe" style="padding:0;margin:0">
          <input type="email" name="rvs_in_email" value="${
            rvtsEmail ? rvtsEmail : ""
          }" style="border:1px solid transparent;width: 150px;height: 30px;font-size: 12px;">
          <input type="hidden" name="my_form_id" value="${formId}">
          ${
            config.iysPost == 1
              ? `<input type="hidden" name="rvs_in_iys_type" value="EPOSTA">
          <input type="hidden" name="rvs_in_iys_source" value="HS_WEB">
          <input type="hidden" name="rvs_in_iys_status" value="ONAY">
          <input type="hidden" name="rvs_in_iys_consent_date" value="">
          <input type="hidden" name="rvs_in_iys_recipient_type" value="BIREYSEL">
          <input type="hidden" name="rvs_in_status_id" value="110">`
              : ""
          }
          ${
            config.optInBox == 1
              ? `<div id="backInStockOptInDiv_${popupId}" style="border:1px solid transparent;margin-top: 10px;display: flex;flex-direction: row;align-items: center;">
              <input type="checkbox" name="rvs_in_optin_email" id="rvs_in_optin_email" value="1">
              <label for="rvs_in_optin_email" style="font-size: 10px;">${decodeURIComponent(
                config.optInBoxText
              )}</label>
          </div>`
              : ""
          }
          <button onclick="submitBackInStock_${popupId}(this,event)" type="submit">${decodeURIComponent(
          config.emailPromptText
        )}</button>
          </form>
          <script>
          var ${formVarName} = document.querySelector('form[name=Subscribe]');
          ${
            config.optInBox == 1
              ? `var ${optInDivVarName} = document.getElementById('backInStockOptInDiv_${popupId}');
          ${optInDivVarName}.addEventListener('animationend',function(){
              this.style.animation ='';
          });`
              : ""
          }
          ${formVarName}.rvs_in_email.addEventListener('animationend',function(){
              this.style.animation ='';
          });
          function submitBackInStock_${popupId}(button,event){
              event.preventDefault();
              var custId = '${custId}';
              var productId = '${productId}';
              var formId = '${formId}';
              var email = ${formVarName}.rvs_in_email.value.trim();
              ${
                config.optInBox == 1
                  ? `if(!${formVarName}.rvs_in_optin_email.checked) {
                  ${optInDivVarName}.style.animation = 'optInWarning 500ms 3';
                  return;
              }`
                  : ""
              }
              if(!email) {
                  ${formVarName}.rvs_in_email.style.animation = 'optInWarning 500ms 3';
                  return;
              }
              function date2str(x, y) {
                  var z = {
                      M: x.getMonth() + 1,
                      d: x.getDate(),
                      h: x.getHours(),
                      m: x.getMinutes(),
                      s: x.getSeconds()
                  };
                  y = y.replace(/(M+|d+|h+|m+|s+)/g, function(v) {
                      return ((v.length > 1 ? "0" : "") + eval('z.' + v.slice(-1))).slice(-2)
                  });
      
      
      
                  return y.replace(/(y+)/g, function(v) {
                      return x.getFullYear().toString().slice(-v.length)
                  });
              }
      
              ${
                config.iysPost == 1
                  ? `${formVarName}.rvs_in_iys_consent_date.value = date2str(new Date(),'yyyy-MM-dd hh:mm:ss');`
                  : ""
              }
              var str='';
              for(var input of ${formVarName}) {
                  if(input.type!=='submit') {
                      str+='&'+input.name+'='+input.value;
                  }
              }
              str=str.substring(1);
              fetch('https://revoform.revotas.com/frm/sv/FormProcessor', {
                  method: 'POST',
                  headers:{
                      "content-type": "application/x-www-form-urlencoded"
                  },
                  body: str
              });
              var wpToken = swGetCookie('revotas_web_push_user');
              fetch('https://f.revotas.com/frm/smartwidgets/save_backinstock_recip.jsp?cust_id='+custId+'&email='+email+(wpToken?('&token_id='+wpToken):'')+'&form_id='+formId+'&product_id='+productId);
              window['backInStockPopup_${popupId}'].close();
          }
          </script>
          `;
  
        var popupConfig = {
          autoCloseDelay: "",
          backgroundColor: "rgba(228, 228, 228, 1)",
          closeDuration: "500ms",
          contentType: "htmlCode",
          cssLinks: "",
          enabled: true,
          hAlign: "center",
          height: "170px",
          html: html,
          nonBlocking: 0,
          overlayClick: "donotclose",
          overlayColor: "rgba(0, 0, 0, 0.25)",
          overlayLock: "true",
          position: "center",
          scriptCode: "",
          showDuration: "500ms",
          trigger: "noTrigger",
          type: "fading",
          vAlign: "center",
          width: "300px",
        };
  
        var popup = fadingPopup(popupConfig, null, null, null, null, true);
  
        window["backInStockPopup_" + popupId] = popup;
  
        var promptText = decodeURIComponent(config.emailPromptText);
        if (insertPosition === "replace") {
          selectedElement.parentElement.replaceChild(button, selectedElement);
        } else {
          selectedElement.insertAdjacentElement(insertPosition, button);
        }
        button.addEventListener("click", function () {
          if (config.iysPost == 1 || config.optInBox == 1 || !rvtsEmail) {
            popup.show(true);
          } else {
            var email = rvtsEmail;
            if (email) {
              fetch("https://revoform.revotas.com/frm/sv/FormProcessor", {
                method: "POST",
                headers: {
                  "content-type": "application/x-www-form-urlencoded",
                },
                body: "rvs_in_email=" + email + "&my_form_id=" + formId,
              });
              var wpToken = swGetCookie("revotas_web_push_user");
              fetch(
                "https://f.revotas.com/frm/smartwidgets/save_backinstock_recip.jsp?cust_id=" +
                  custId +
                  "&email=" +
                  email +
                  (wpToken ? "&token_id=" + wpToken : "") +
                  "&form_id=" +
                  formId +
                  "&product_id=" +
                  productId
              );
            }
          }
        });
        return button;
      }
  
      function rvtsDealOfDay(params, popupId, popupName) {
        var isOpen = true;
        let settings = params.dealOfDaySettings;
        settings.headerText = decodeURIComponent(settings.headerText);
        settings.imageLink = decodeURIComponent(settings.imageLink);
        settings.buttonLink = decodeURIComponent(settings.buttonLink);
        settings.messageText = decodeURIComponent(settings.messageText);
        settings.buttonText = decodeURIComponent(settings.buttonText);
        settings.widgetHeaderText = decodeURIComponent(settings.widgetHeaderText);
        function Widget() {
          rvtsPushSmartWidgetActivity(null, popupId, popupName, 0);
          var Div = document.createElement("div");
          Div.setAttribute("id", "widgetId");
          Div.style.height = "100px";
          Div.style.width = "105px";
          Div.style.bottom = "30px";
          Div.style.left = "25px";
          Div.style.setProperty("position", "fixed", "important");
          Div.style.zIndex = "99999";
          Div.style.borderRadius = "2px solid rgb(217, 217, 217)";
          Div.style.overflow = "hidden";
          Div.style.boxShadow = "0px 0px 4px 1px rgb(66 66 66 0.3)";
          Div.style.borderRadius = "90px";
          Div.style.display = "flex";
          Div.style.justifyContent = "center";
          Div.style.backgroundColor = settings.widgetBGColor || "#CD4344";
  
          var label = document.createElement("label");
          label.setAttribute("id", "labelId");
          label.style.textAlign = "center";
          label.style.fontSize = "18px";
          label.style.color = settings.widgetTextColor || "white";
          label.style.top = "30px";
          label.style.position = "absolute";
          label.style.wordSpacing = "1px";
  
          label.innerText = settings.widgetHeaderText || "Günün Fırsatı";
          Div.appendChild(label);
  
          var svg = document.createElement("svg");
  
          svg.setAttribute("id", "svgId");
          svg.style.position = "absolute";
          svg.style.display = "none";
  
          svg.style.left = "8px";
          svg.innerHTML =
            '<svg width="90px" height="100px" viewBox="0 0 16 16" class="bi bi-x" color="white" fill="currentColor" xmlns="http://www.w3.org/2000/svg"> <path fill-rule="evenodd" d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/> </svg>';
  
          Div.appendChild(svg);
          return Div;
        }
  
        var rvtsWidget = Widget();
  
        function Box() {
          var Div = document.createElement("div");
          Div.style.height = "223px";
          Div.style.width = "439px";
          Div.style.setProperty("position", "fixed", "important");
          Div.style.zIndex = "99999";
          Div.style.borderRadius = "2px solid rgb(217, 217, 217)";
          Div.style.overflow = "hidden";
          Div.style.boxShadow = "0px 0px 4px 1px rgb(66 66 66 0.3)";
          Div.style.borderRadius = "9px";
          Div.style.backgroundColor = "white";
          Div.style.marginLeft = "25px";
          Div.style.marginTop = "25px";
          Div.classList.add("rvts-deal-of-the-day-container");
          var dealStyle = document.createElement("style");
          dealStyle.innerHTML =
            "@media only screen and (max-width: 500px) {.rvts-deal-of-the-day-container { width: calc(100% - 16px)!important;max-width: 439px!important;min-width: 300px!important; margin-left: 8px!important;  margin-right: 8px!important;  left: 0px!important; bottom:135px!important; top:unset!important }}";
          document.head.appendChild(dealStyle);
  
          document.body.appendChild(Div);
  
          document.body.appendChild(Div);
  
          var newDiv = document.createElement("div");
          newDiv.style.height = "48px";
          newDiv.style.width = "100%";
          newDiv.style.display = "flex";
          newDiv.style.justifyContent = "center";
          newDiv.style.alignItems = "center";
          newDiv.style.backgroundColor = settings.headerBGColor || "#CD4344";
  
          Div.appendChild(newDiv);
  
          var label = document.createElement("label");
          label.style.textAlign = "center";
          label.style.fontSize = "x-large";
          label.style.fontWeight = "bold";
          label.style.color = settings.headerTextColor || "white";
  
          label.innerHTML = settings.headerText;
          newDiv.appendChild(label);
  
          var infoDiv = document.createElement("div");
          infoDiv.setAttribute("id", "info-div");
          infoDiv.style.width = "100%";
          infoDiv.style.height = "80%";
          infoDiv.style.display = "flex";
          infoDiv.style.justifyContent = "space-around";
          infoDiv.style.alignItems = "center";
          infoDiv.style.padding = "5px";
  
          var image = document.createElement("img");
          image.setAttribute("id", "deal-of-day-image");
          image.style.width = settings.imageWidth + "px";
          image.style.height = settings.imageHeight + "px";
          image.style.borderRadius = settings.imageBorderRadius + "px";
  
          image.src = settings.imageLink || "";
  
          infoDiv.appendChild(image);
  
          var info = document.createElement("div");
          info.setAttribute("id", "deal-of-day-message");
          info.style.color = "#0e0000";
          info.style.fontSize = "medium";
          info.style.fontWeight = "600";
          info.style.width = "35%";
          info.style.display = "flex";
          info.style.flexDirection = "column";
          info.style.justifyContent = "center";
          info.innerHTML =
            settings.messageText || "Ares Saklama Kabı 12 cm 3 Adet";
  
          infoDiv.appendChild(info);
  
          var link = document.createElement("a");
          info.setAttribute("id", "deal-of-day-button");
          info.classList.add("ql-editor");
          link.style.textAlign = "center";
          link.style.color = settings.buttonTextColor || "white";
          link.style.backgroundColor = settings.buttonBGColor || "#CD4344";
          link.style.fontSize = "medium";
          link.style.fontWeight = "bold";
          link.style.borderRadius = "0px";
          link.href = settings.buttonLink || "";
          link.style.display = "flex";
          link.style.justifyContent = "center";
          link.style.alignItems = "center";
          link.style.padding = "5px";
          link.innerHTML = settings.buttonText || "Hemen Tıkla";
  
          infoDiv.appendChild(link);
  
          Div.appendChild(infoDiv);
  
          return Div;
        }
  
        var rvtsBox = Box();
        rvtsBox.style.display = "none";
        document.body.appendChild(rvtsWidget);
        document.body.appendChild(rvtsBox);
  
        rvtsWidget.addEventListener("click", function () {
          rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
          var clientRect = rvtsWidget.getBoundingClientRect();
          rvtsBox.style.top = clientRect.top - 150 + "px";
          rvtsBox.style.left = clientRect.right + 2 + "px";
  
          if (isOpen) {
            rvtsBox.style.display = "";
            document.getElementById("labelId").style.display = "none";
            document.getElementById("svgId").style.display = "";
            isOpen = false;
          } else {
            rvtsBox.style.display = "none";
            document.getElementById("labelId").style.display = "";
            document.getElementById("svgId").style.display = "none";
            isOpen = true;
          }
        });
        var quilLink = document.createElement("link");
        quilLink.rel = "stylesheet";
        quilLink.href = "https://cdn.quilljs.com/1.3.6/quill.snow.css";
        document.head.append(quilLink);
  
        if (settings.dealOfDayCss) {
          var style = document.createElement("style");
          style.innerHTML = decodeURIComponent(settings.dealOfDayCss);
          document.head.appendChild(style);
        }
      }
  
      function hexToRgbA(hex, alpha) {
        if (!hex) {
          console.error("Hex değeri tanımlanmamış!");
          return "";
        }
  
        hex = hex.replace("#", "");
  
        // Parse the hex value into individual color components
        const r = parseInt(hex.substring(0, 2), 16);
        const g = parseInt(hex.substring(2, 4), 16);
        const b = parseInt(hex.substring(4, 6), 16);
  
        // Ensure the alpha value is between 0 and 1
        alpha = Math.min(1, Math.max(0, alpha));
  
        // Create the RGBA string
        const rgba = `rgba(${r},${g},${b},${alpha})`;
  
        return rgba;
      }
      function rvtsRecentlyView(
        config,
        custId,
        popupId,
        popupName,
        isLivePreview
      ) {
        let recentlyData = config;
        let recentlyFlag = false;
        let revoDrawer = document.createElement("div");
        revoDrawer.style = "position:fixed;top:50%;right:0;z-index:99999";
  
        let recentlyContainer = document.createElement("div");
        recentlyContainer.style =
          "display:flex;position:relative;right:-310px;transform:translateX(0%);transition: right 0.5s ease;transform:translateY(-50%);";
        let openButton = document.createElement("div");
        openButton.style =
          "height:70px;position:relative;top:50px;cursor:pointer;background-color:rgba(255,102,0,0.5);color:#ffffff;width:60px;border-top-left-radius:100%;border-bottom-left-radius:100%;display:flex;justify-content:center;align-items:center;z-index:0;";
        openButton.style.setProperty(
          "background-color",
          hexToRgbA(recentlyData?.arrowColor, 0.5),
          "important"
        );
        openButton.addEventListener("click", function () {
          recentlyFlag = !recentlyFlag;
          if (recentlyFlag === true) {
            recentlyContainer.style =
              "display:flex;justify-content:start;position:fixed;top:50%;right:0px !important;transform:translateX(0%);transition: right 0.5s ease;transform:translateY(-50%);";
          } else {
            recentlyContainer.style =
              "display:flex;position:relative;right:-310px;transform:translateX(0%);transition: right 0.5s ease;transform:translateY(-50%);";
          }
        });
  
        let openButtonItem = document.createElement("div");
        openButtonItem.style =
          "height:55px;position:absolute;right:0px;cursor:pointer;color:#ffffff;width:52px;border-top-left-radius:100%;border-bottom-left-radius:100%;display:flex;justify-content:center;align-items:center;z-index:1;";
        openButtonItem.style.setProperty(
          "background-color",
          hexToRgbA(recentlyData?.arrowColor, 1),
          "important"
        );
  
        let recentlyIcon = `<svg width="17" height="25" viewBox="0 0 17 25" fill="none" xmlns="http://www.w3.org/2000/svg">
                    <path d="M14.2778 2C10.19 5.3871 6.08778 8.77419 2 12.1613C6.33333 15.7787 10.6667 19.3826 15 23" stroke="white" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" />
                  </svg>`;
  
        openButtonItem.innerHTML = recentlyIcon;
        openButton.appendChild(openButtonItem);
        recentlyContainer.appendChild(openButton);
        revoDrawer.appendChild(recentlyContainer);
  
        let drawerContent = document.createElement("div");
        drawerContent.style =
          "width:300px;height:auto;display:flex;justify-content:start;flex-direction:column;box-shadow:rgba(0, 0, 0, 0.35) 0px 5px 15px;border-top-left-radius:20px;border-bottom-left-radius:20px;padding:20px;";
        drawerContent.style.setProperty(
          "background-color",
          hexToRgbA(recentlyData?.containerBgColor, 1),
          "important"
        );
  
        let drawerTitle = document.createElement("div");
        drawerTitle.style = "padding:10px 15px;font-weight:700;";
        drawerTitle.style.setProperty(
          "font-size",
          recentlyData?.titleSize?.toString() + "px",
          "important"
        );
        drawerTitle.style.setProperty(
          "color",
          recentlyData?.titleColor,
          "important"
        );
        drawerTitle.style.setProperty(
          "text-align",
          recentlyData.titleAlign,
          "important"
        );
        drawerTitle.style.setProperty(
          "font-family",
          recentlyData.titleFontFamily,
          "important"
        );
        drawerTitle.style.setProperty(
          "font-weight",
          recentlyData.titleFont,
          "important"
        );
        if (recentlyData.titleFontStyle === "italic") {
          drawerTitle.style.setProperty(
            "font-style",
            recentlyData.titleFontStyle,
            "important"
          );
        } else {
          drawerTitle.style.setProperty("font-style", "normal", "important");
          drawerTitle.style.setProperty(
            "text-decoration",
            recentlyData.titleFontStyle === "normal"
              ? "none"
              : recentlyData.titleFontStyle,
            "important"
          );
        }
        drawerTitle.innerText = decodeURIComponent(
          decodeURIComponent(recentlyData?.title)
        );
  
        drawerContent.appendChild(drawerTitle);
        var recentlyProducts =
          localStorage.getItem("rvts_product_history_array") &&
          decodeURIComponent(localStorage.getItem("rvts_product_history_array"));
        recentlyProducts = JSON.parse(recentlyProducts);
        function saveRecentlyActivity(actType) {
          if (!isLivePreview) {
            var fetchParams =
              "cust_id=" +
              custId +
              "&popup_id=" +
              popupId +
              "&form_id=0&user_agent=" +
              navigator.userAgent +
              "&activity_type=" +
              actType +
              "&session_id=" +
              rvtsSessionId;
            if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
            fetchParams +=
              "&url=" +
              window.location.href.split("&").join(encodeURIComponent("&"));
            if (/Mobi|Android/i.test(navigator.userAgent)) {
              fetchParams += "&device=" + "1";
            } else {
              fetchParams += "&device=" + "2";
            }
            fetch(
              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                fetchParams
            );
            if (actType == 1) saveSwSource(popupId);
            rvtsPushGaEvent(actType, popupName);
          }
        }
  
        recentlyProducts?.map((item, key) => {
          if (key < 4) {
            let revoProduct = document.createElement("div");
            revoProduct.setAttribute("key", key);
            revoProduct.style =
              "display:flex;padding: 10px 0px;gap:10px;border-bottom:1px solid #e3e3e3;height:auto;cursor:pointer;";
            revoProduct.addEventListener("click", function () {
              window.location.href = item[0]?.link;
              saveRecentlyActivity(1); //click
            });
  
            let recentlyProductImageDiv = document.createElement("div");
            recentlyProductImageDiv.style =
              "display:flex;justify-content:center;align-items:center;";
            let recentlyProductImage = document.createElement("img");
            recentlyProductImage.src = item[0]?.image_link;
            recentlyProductImage.style = "object-fit:contain;";
            recentlyProductImage.style.setProperty(
              "width",
              recentlyData?.imageWidth?.toString() + "px",
              "important"
            );
            recentlyProductImage.style.setProperty(
              "height",
              recentlyData?.imageWidth?.toString() + "px",
              "important"
            );
  
            recentlyProductImageDiv.appendChild(recentlyProductImage);
  
            let productContent = document.createElement("div");
            productContent.style = "display:flex;flex-direction:column;gap:10px;";
  
            let recentlyProductName = document.createElement("span");
            recentlyProductName.style.setProperty(
              "color",
              recentlyData?.productTitleColor,
              "important"
            );
            recentlyProductName.style.setProperty(
              "font-size",
              recentlyData?.productTitleSize?.toString() + "px",
              "important"
            );
            recentlyProductName.style.setProperty(
              "text-align",
              recentlyData.productTitleAlign,
              "important"
            );
            recentlyProductName.style.setProperty(
              "font-family",
              recentlyData.productTitleFontFamily,
              "important"
            );
            recentlyProductName.style.setProperty(
              "font-weight",
              recentlyData.productTitleFont,
              "important"
            );
            if (recentlyData.productTitleFontStyle === "italic") {
              recentlyProductName.style.setProperty(
                "font-style",
                recentlyData.productTitleFontStyle,
                "important"
              );
            } else {
              recentlyProductName.style.setProperty(
                "font-style",
                "normal",
                "important"
              );
              recentlyProductName.style.setProperty(
                "text-decoration",
                recentlyData.productTitleFontStyle === "normal"
                  ? "none"
                  : recentlyData.productTitleFontStyle,
                "important"
              );
            }
            recentlyProductName.innerText = item[0]?.name;
  
            let productPriceBar = document.createElement("div");
            productPriceBar.style =
              "display:flex;justify-content:start;align-items:center;gap:10px";
  
            let recentlyProductPrice = document.createElement("span");
  
            recentlyProductPrice.style =
              "text-decoration:line-through;white-space:nowrap;";
            recentlyProductPrice.innerText = item[0]?.product_price;
            recentlyProductPrice.style.setProperty(
              "color",
              recentlyData?.priceColor,
              "important"
            );
            recentlyProductPrice.style.setProperty(
              "font-size",
              recentlyData?.priceSize?.toString() + "px",
              "important"
            );
  
            let recentlyProductSalesPrice = document.createElement("span");
  
            recentlyProductSalesPrice.innerText = item[0]?.product_sales_price
              ? item[0]?.product_sales_price
              : "";
            recentlyProductSalesPrice.style =
              "font-weight:bold;white-space:nowrap;";
            recentlyProductSalesPrice.style.setProperty(
              "color",
              recentlyData?.salesPriceColor,
              "important"
            );
            recentlyProductSalesPrice.style.setProperty(
              "font-size",
              recentlyData?.salesPriceSize?.toString() + "px",
              "important"
            );
  
            productPriceBar.appendChild(recentlyProductPrice);
            productPriceBar.appendChild(recentlyProductSalesPrice);
  
            productContent.appendChild(recentlyProductName);
            productContent.appendChild(productPriceBar);
  
            revoProduct.appendChild(recentlyProductImageDiv);
            revoProduct.appendChild(productContent);
            drawerContent.appendChild(revoProduct);
            recentlyContainer.appendChild(drawerContent);
          }
        });
  
        document.body.append(revoDrawer);
        saveRecentlyActivity(0); //view
      }
      function rvtsBlockedWebpush(
        config,
        custId,
        popupId,
        popupName,
        isLivePreview
      ) {
        let settings = config;
        let blockContainer = document.createElement("div");
        blockContainer.style = "position:fixed;top:0;left:0;z-index:9999;";
        function saveBlockedWebpushActivity(actType) {
          if (!isLivePreview) {
            var fetchParams =
              "cust_id=" +
              custId +
              "&popup_id=" +
              popupId +
              "&form_id=0&user_agent=" +
              navigator.userAgent +
              "&activity_type=" +
              actType +
              "&session_id=" +
              rvtsSessionId;
            if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
            fetchParams +=
              "&url=" +
              window.location.href.split("&").join(encodeURIComponent("&"));
            if (/Mobi|Android/i.test(navigator.userAgent)) {
              fetchParams += "&device=" + "1";
            } else {
              fetchParams += "&device=" + "2";
            }
            fetch(
              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                fetchParams
            );
            if (actType == 1) saveSwSource(popupId);
            rvtsPushGaEvent(actType, popupName);
          }
        }
        let blockContainerItem = document.createElement("div");
        blockContainerItem.style =
          "display:flex;flex-direction:column;justify-content:center;align-items:center;text-align:center;max-width:330px;width:100%;background-color:white;border-radius:10px;box-shadow:0 4px 10px rgba(0,0,0,0.4);padding:20px 10px;";
  
        let blockImage = document.createElement("img");
        blockImage.src = settings.imageLink;
        blockImage.style.setProperty(
          "width",
          settings.imageWidth?.toString() + "px",
          "important"
        );
        blockImage.style.setProperty(
          "height",
          settings.imageHeight?.toString() + "px",
          "important"
        );
  
        let blockDesc = document.createElement("p");
  
        if (settings.descFontStyle === "none") {
          blockDesc.style.setProperty("font-style", "normal", "important");
        } else {
          blockDesc.style.setProperty(
            "font-style",
            settings.descFontStyle,
            "important"
          );
        }
        blockDesc.style.setProperty(
          "text-decoration",
          settings.descFontStyle,
          "important"
        );
        blockDesc.style.setProperty(
          "text-align",
          settings.descAlign,
          "important"
        );
        blockDesc.style.setProperty(
          "font-family",
          settings.descFontFamily,
          "important"
        );
        blockDesc.style.setProperty("font-weight", settings.descFont);
        blockDesc.style.setProperty(
          "font-size",
          settings.descSize?.toString() + "px",
          "important"
        );
        blockDesc.style.setProperty("color", settings.descColor, "important");
        blockDesc.innerText = decodeURIComponent(decodeURIComponent(config.desc));
        let blockListBar = document.createElement("div");
        blockListBar.style = "display:flex;justify-content:start;gap:10px;";
  
        let step1 = document.createElement("span");
        step1.style = "color:#ff6600;font-weight:bold;font-size:12px;";
  
        if (settings.stepFontStyle === "none") {
          step1.style.setProperty("font-style", "normal", "important");
        } else {
          step1.style.setProperty(
            "font-style",
            settings.stepFontStyle,
            "important"
          );
        }
  
        step1.style.setProperty(
          "text-decoration",
          settings.stepFontStyle,
          "important"
        );
        step1.style.setProperty(
          "font-family",
          settings.stepFontFamily,
          "important"
        );
        step1.style.setProperty(
          "font-size",
          settings.stepSize?.toString() + "px",
          "important"
        );
        step1.style.setProperty("font-weight", settings.stepFont, "important");
        step1.innerText = "1.";
  
        let step1Text = document.createElement("span");
        step1Text.style = "max-width:300px;";
        if (settings.stepFontStyle === "none") {
          step1Text.style.setProperty("font-style", "normal", "important");
        } else {
          step1Text.style.setProperty(
            "font-style",
            settings.stepFontStyle,
            "important"
          );
        }
        step1Text.style.setProperty(
          "text-decoration",
          settings.stepFontStyle,
          "important"
        );
        step1Text.style.setProperty(
          "font-family",
          settings.stepFontFamily,
          "important"
        );
        step1Text.style.setProperty(
          "font-size",
          settings.stepSize.toString() + "px",
          "important"
        );
        step1Text.style.setProperty(
          "font-weight",
          settings.stepFont,
          "important"
        );
        step1Text.style.setProperty("color", settings.stepColor, "important");
        step1Text.innerHTML = decodeURIComponent(settings.step1);
  
        blockListBar.appendChild(step1);
        blockListBar.appendChild(step1Text);
  
        let blockListBar1 = document.createElement("div");
        blockListBar1.style = "display:flex;justify-content:start;gap:10px;";
  
        let step2 = document.createElement("span");
        step2.style = "color:#ff6600;font-weight:bold;font-size:12px;";
  
        if (settings.stepFontStyle === "none") {
          step2.style.setProperty("font-style", "normal", "important");
        } else {
          step2.style.setProperty(
            "font-style",
            settings.stepFontStyle,
            "important"
          );
        }
  
        step2.style.setProperty(
          "text-decoration",
          settings.stepFontStyle,
          "important"
        );
        step2.style.setProperty(
          "font-family",
          settings.stepFontFamily,
          "important"
        );
        step2.style.setProperty(
          "font-size",
          settings.stepSize?.toString() + "px",
          "important"
        );
        step2.style.setProperty("font-weight", settings.stepFont, "important");
        step2.innerText = "2.";
  
        let step2Text = document.createElement("span");
        step2Text.style = "max-width:300px;";
        if (settings.stepFontStyle === "none") {
          step2Text.style.setProperty("font-style", "normal", "important");
        } else {
          step2Text.style.setProperty(
            "font-style",
            settings.stepFontStyle,
            "important"
          );
        }
        step2Text.style.setProperty(
          "text-decoration",
          settings.stepFontStyle,
          "important"
        );
        step2Text.style.setProperty(
          "font-family",
          settings.stepFontFamily,
          "important"
        );
        step2Text.style.setProperty(
          "font-size",
          settings.stepSize.toString() + "px",
          "important"
        );
        step2Text.style.setProperty(
          "font-weight",
          settings.stepFont,
          "important"
        );
        step2Text.style.setProperty("color", settings.stepColor, "important");
        step2Text.innerText = decodeURIComponent(settings.step2);
  
        blockListBar1.appendChild(step2);
        blockListBar1.appendChild(step2Text);
  
        let blockButton = document.createElement("button");
        blockButton.id = "prm";
        blockButton.style =
          "padding:10px 20px;border:none;border-radius:5px;cursor:pointer;";
        blockButton.style.setProperty(
          "width",
          settings.buttonWidth?.toString() + "px",
          "important"
        );
        blockButton.style.setProperty(
          "height",
          settings.buttonHeight?.toString() + "px",
          "important"
        );
  
        if (settings.buttonFontStyle === "none") {
          blockButton.style.setProperty("font-style", "normal", "important");
        } else {
          blockButton.style.setProperty(
            "font-style",
            settings.buttonFontStyle,
            "important"
          );
        }
        blockButton.style.setProperty(
          "text-decoration",
          settings.buttonFontStyle,
          "important"
        );
        blockButton.style.setProperty(
          "font-family",
          settings.fontFamily,
          "important"
        );
        blockButton.style.setProperty(
          "font-size",
          settings.buttonFontSize?.toString() + "px",
          "important"
        );
        blockButton.style.setProperty("color", settings.buttonColor, "important");
        blockButton.style.setProperty(
          "font-weight",
          settings.buttonFont,
          "important"
        );
        blockButton.style.setProperty(
          "text-align",
          settings.buttonAlign,
          "important"
        );
  
        if (settings.isGradient === true) {
          blockButton.style.setProperty(
            "background",
            `linear-gradient(90deg, ${settings.bg1}, ${settings.bg2})`,
            "important"
          );
        } else {
          blockButton.style.setProperty("background", settings.bg1, "important");
        }
        blockButton.innerText = decodeURIComponent(settings.buttonText);
  
        blockButton.addEventListener("click", function () {
          saveBlockedWebpushActivity(1); //click
        });
  
        blockContainerItem.appendChild(blockImage);
        blockContainerItem.appendChild(blockDesc);
        blockContainerItem.appendChild(blockListBar);
        blockContainerItem.appendChild(blockListBar1);
        blockContainerItem.appendChild(blockButton);
        blockContainer.appendChild(blockContainerItem);
  
        document.body.append(blockContainer);
        saveBlockedWebpushActivity(0); //view
      }
  
      function rvtsWhatsapp(config, custId, popupId, popupName, isLivePreview) {
        let settings = config.whatsappSettings;
        let whatsappIcon =
          '<i class="fa fa-whatsapp" style="font-size:23px;padding-right:5px"></i>';
        let buttonDiv = document.createElement("div");
        buttonDiv.style = "display:flex;justify-content:center;";
        buttonDiv.classList.add("whatsappbuttondiv");
        let orderButton = document.createElement("button");
        orderButton.style =
          "width:auto;max-width:450px;height:40px;background-color:green;color:#fff;border:none;display:flex;align-items:center";
        orderButton.style.setProperty("color", settings.buttonTextColor);
        orderButton.style.setProperty("background-color", settings.buttonBGColor);
        orderButton.innerHTML =
          whatsappIcon + decodeURIComponent(settings.button1Text);
        orderButton.classList.add("whatsappbutton");
        function saveWhatsAppActivity(actType) {
          if (!isLivePreview) {
            var fetchParams =
              "cust_id=" +
              custId +
              "&popup_id=" +
              popupId +
              "&form_id=0&user_agent=" +
              navigator.userAgent +
              "&activity_type=" +
              actType +
              "&session_id=" +
              rvtsSessionId;
            if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
            fetchParams +=
              "&url=" +
              window.location.href.split("&").join(encodeURIComponent("&"));
            if (/Mobi|Android/i.test(navigator.userAgent)) {
              fetchParams += "&device=" + "1";
            } else {
              fetchParams += "&device=" + "2";
            }
            fetch(
              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                fetchParams
            );
            if (actType == 1) saveSwSource(popupId);
            rvtsPushGaEvent(actType, popupName);
          }
        }
  
        let orderMessage = `${settings.orderMessage} ${window.location.href}`;
        orderButton.addEventListener("click", function () {
          saveWhatsAppActivity(1);
          window.open(
            `https://api.whatsapp.com/send?phone=${decodeURIComponent(
              settings.number
            )}&text=${orderMessage}`
          );
        });
        let adviceButton = document.createElement("button");
        adviceButton.style =
          "width:auto;max-width:450px;height:40px;background-color:green;color:#fff;border:none;margin-left:20px;display:flex;align-items:center";
        adviceButton.style.setProperty("color", settings.buttonTextColor);
        adviceButton.style.setProperty(
          "background-color",
          settings.buttonBGColor
        );
        adviceButton.innerHTML =
          whatsappIcon + decodeURIComponent(settings.button2Text);
        adviceButton.classList.add("whatsappbutton");
        let adviceMessage = `${settings.adviceMessage} ${window.location.href}`;
        adviceButton.addEventListener("click", function () {
          saveWhatsAppActivity(1);
          window.open(
            `https://api.whatsapp.com/send?phone=&text=${adviceMessage}`
          );
        });
        var link = document.createElement("link");
        link.rel = "stylesheet";
        link.href =
          "https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css";
        document.head.appendChild(link);
        buttonDiv.appendChild(orderButton);
        buttonDiv.appendChild(adviceButton);
  
        let position = decodeURIComponent(settings.insertPosition);
        let querySelector = decodeURIComponent(settings.querySelector);
  
        if (querySelector) {
          if (position === "replace") {
            document
              .querySelector(querySelector)
              .parentNode.replaceChild(
                buttonDiv,
                document.querySelector(querySelector)
              );
          } else {
            document
              .querySelector(querySelector)
              .insertAdjacentElement(position, buttonDiv);
          }
        } else {
          buttonDiv.style =
            "position:fixed;bottom:60px;display:flex;width:100%;justify-content:center;height:40px";
          document.body.appendChild(buttonDiv);
        }
  
        if (settings.whatsappCss) {
          var style = document.createElement("style");
          style.innerHTML = decodeURIComponent(settings.whatsappCss);
          document.head.appendChild(style);
        }
        saveWhatsAppActivity(0);
      }
  
      function rvtsSpinWheel(config, custId, popupId, popupName, isLivePreview) {
        console.log(config, "config");
        let body = document.createElement("div");
        document.body.appendChild(body);
        body.style.position = "fixed";
        /* if (window.innerWidth <= 768) { // Mobil cihazlar için
              body.style.top = '20%';
          } else { // Diğer cihazlar için
              body.style.top = '37%';
          }
          body.style.right = '0'; */
        body.style.zIndex = "999";
        body.style.borderRadius = "7px";
        body.className = `spin-preview-container fixed-box ${
          config?.vAlign === "top" && config?.hAlign === "left"
            ? "top-left"
            : config?.vAlign === "top" && config?.hAlign === "center"
            ? "top-center"
            : config?.vAlign === "top" && config?.hAlign === "right"
            ? "top-right"
            : config?.vAlign === "center" && config?.hAlign === "left"
            ? "center-left"
            : config?.vAlign === "center" && config?.hAlign === "center"
            ? "center-center"
            : config?.vAlign === "center" && config?.hAlign === "right"
            ? "center-right"
            : config?.vAlign === "bottom" && config?.hAlign === "left"
            ? "bottom-left"
            : config?.vAlign === "bottom" && config?.hAlign === "center"
            ? "bottom-center"
            : config?.vAlign === "bottom" && config?.hAlign === "right"
            ? "bottom-right"
            : ""
        }`;
  
        let styleTag = document.getElementById("dynamic-style");
        if (!styleTag) {
          styleTag = document.createElement("style");
          styleTag.id = "dynamic-style";
          document.head.appendChild(styleTag);
        }
        const totalItems = config.wheelData.length;
        const sliceWidth = 360 / totalItems;
  
        // JSX benzeri şablon oluşturma
        body.innerHTML = `
              <div class="container-rvtsSpinWheel">
              <div class="close-btn" style="position: absolute; top: 10px; right: 10px; cursor: pointer; font-size: 20px; font-weight: bold; color: black;">✖</div>
                  <div style="position: relative; width: 300px; height: 300px; margin: 0 auto;" class="spin-wheel">
                      <div class="wheel" style="border: 1px solid ${
                        config.spinDesign.arc
                      }; position: relative; width: 300px; height: 300px; border-radius: 50%; overflow: hidden; transform-origin: center center; transform: rotate(200deg);">
                          ${config.wheelData
                            .map(
                              (item, index) => `
                              <div class="slice" style="background-color: ${
                                item.color
                              }; transform: rotate(${
                                sliceWidth * index
                              }deg); width: 50%; height: 100%; position: absolute; top: 0; left: 0;">
                                  <div style="position: absolute; font-family: sans-serif; left: 38%; top: 57%; text-align: center; transform: translate(-50%, -50%) rotate(160deg); font-size: ${
                                    item.weight
                                  };">
                                      ${decodeURIComponent(item.title)}
                                  </div>
                              </div>
                          `
                            )
                            .join("")}
                      </div>
                      <div class="center-dot" style="background-color: ${
                        config.spinDesign.dots
                      }; border: 1px solid ${
          config.spinDesign.circle
        }; width: 20px; height: 20px; border-radius: 50%; position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%);"></div>
                      <svg style="position: absolute; top: 136px; left: 257px;" width="76" height="42" viewBox="0 0 76 42" fill="none" xmlns="http://www.w3.org/2000/svg">
                          <g filter="url(#filter0_d_1_1114)">
                              <path d="M72 16.9994C72 7.60946 62.947 -3.95721e-07 51.7839 -8.83675e-07C40.6179 -1.37176e-06 4 16.9994 4 16.9994C4 16.9994 40.6179 34 51.7839 34C62.947 34 72 26.3857 72 16.9994Z" fill="${
                                config.spinDesign.sticks
                              }" />
                          </g>
                      </svg>
                  </div>
                  <div id="winMessage" class="form-container">
                      <div style="color: black; font-size: 20px; font-family: Poppins; font-weight: bold;">
                          ${decodeURIComponent(config.spinDesign.title)}
                      </div>
                      <div style="color: black; font-size: 12px; font-family: Poppins; margin-bottom: 10px;">
                          ${decodeURIComponent(config.spinDesign.text)}
                      </div>
                      <form id="spinForm">
                      <div style="display: flex; gap: 10px; align-items: center; justify-content: center; width: 250px; margin: 10px auto;">
                          ${
                            config.spinDesign.name === 1
                              ? `
                              <div style="display: flex; flex-direction: column; align-items: center;">
                                  <input type="text" class="nameSpin" placeholder="Surname" 
                                      style="border-radius: 5px; border: 1px solid #898989; background-color: transparent; width: 120px; height: 28px; text-align: center;" />
                                  <div class="error-textSpin firstName" style="height: 16px;  color: red;"></div>
                              </div>
                          `
                              : ""
                          }
                          
                          ${
                            config.spinDesign.surname === 1
                              ? `
                              <div style="display: flex; flex-direction: column; align-items: center;">
                                  <input type="text" class="surnameSpin" placeholder="Lastname" 
                                      style="border-radius: 5px; border: 1px solid #898989; background-color: transparent; width: 120px; height: 28px; text-align: center;" />
                                  <div class="error-textSpin lastName" style="height: 16px;  color: red;"></div>
                              </div>
                          `
                              : ""
                          }
                      </div>
                      <input type="email" class="emailSpin" placeholder="Email Address"  
                          style="border: 1px solid #898989; border-radius: 5px; background-color: transparent; width: 196px; height: 28px; text-align: center; margin-bottom: 5px;" />
                      <div class="error-textSpin email" style="height: 16px;  color: red; text-align: center;"></div>
                      <button type="submit" 
                          style="background-color: ${
                            config.spinDesign.btnColor
                          }; margin-top: 10px; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; font-size: 16px;">
                          ${decodeURIComponent(config.spinDesign.btnText)}
                      </button>
                      ${
                        config.spinDesign.policy === 1
                          ? `
                          <div style="display: flex;justify-content: center; align-items: center; gap: 8px; justify-content: justify; margin-top: 20px;">
                              <input type="checkbox" id="policyCheckbox" 
                                  style="appearance: none; width: 16px; height: 16px; border: 1px solid #898989; border-radius: 50%; cursor: pointer;">
                              <a href="${decodeURIComponent(
                                config.spinDesign.policyUrl
                              )}" target="_blank" rel="noopener noreferrer" 
                                  style="font-size: 11px; font-family: Poppins; color: black; text-decoration: underline;">
                                  ${decodeURIComponent(
                                    config.spinDesign.policyText
                                  )}
                              </a>
                          </div>`
                          : ""
                      }
                      <div class="error-textSpin privacyPolicy" style="height: 16px;  color: red; text-align: left;"></div>
                  </form>
      
                  </div>
              </div>
          `;
  
        const closeButton = document.querySelector(".close-btn");
  
        if (closeButton) {
          closeButton.addEventListener("click", function () {
            const spinWheelContainer = document.querySelector(
              ".container-rvtsSpinWheel"
            );
            if (spinWheelContainer) {
              spinWheelContainer.style.display = "none";
            }
          });
        }
  
        const formId = config.integration;
        function saveSpinWheelActivity(actType) {
          if (!isLivePreview) {
            var fetchParams =
              "cust_id=" +
              custId +
              "&popup_id=" +
              popupId +
              "&form_id=" +
              formId +
              "&user_agent=" +
              navigator.userAgent +
              " & activity_type=" +
              actType +
              " & session_id=" +
              rvtsSessionId;
            if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
            fetchParams +=
              "&url=" +
              window.location.href.split("&").join(encodeURIComponent("&"));
            if (/Mobi|Android/i.test(navigator.userAgent)) {
              fetchParams += "&device=" + "1";
            } else {
              fetchParams += "&device=" + "2";
            }
            fetch(
              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                fetchParams
            );
            if (actType == 1) saveSwSource(popupId);
            rvtsPushGaEvent(actType, popupName);
          }
        }
        saveSpinWheelActivity(0); //view
  
        if (config.spinDesign.iysPost === 1) {
          const iysType = document.createElement("input");
          iysType.id = "revo-iys";
          iysType.name = "iys_type";
          iysType.setAttribute("value", "EPOSTA");
  
          const isySource = document.createElement("input");
          isySource.id = "iysSource";
          isySource.name = "iys_source";
          isySource.setAttribute("value", "HS_WEB");
  
          const iysStatus = document.createElement("input");
          iysStatus.id = "iys_status";
          iysStatus.name = "iys_status";
          iysStatus.setAttribute("value", "ONAY");
  
          const iysRecipient = document.createElement("input");
          iysRecipient.id = "iysRecipient";
          iysRecipient.name = "iys_recipient_type";
          iysRecipient.setAttribute("value", "BIREYSEL");
  
          const iysConsent = document.createElement("input");
          iysConsent.id = "iysConset";
          iysConsent.name = "iys_consent_date";
  
          const currentDate = new Date();
          const formattedDate = `${currentDate.getFullYear()}-${(
            currentDate.getMonth() + 1
          )
            .toString()
            .padStart(2, "0")}-${currentDate
            .getDate()
            .toString()
            .padStart(2, "0")} ${currentDate
            .getHours()
            .toString()
            .padStart(2, "0")}:${currentDate
            .getMinutes()
            .toString()
            .padStart(2, "0")}:${currentDate
            .getSeconds()
            .toString()
            .padStart(2, "0")}`;
          iysConsent.setAttribute("value", formattedDate);
  
          // Gizli inputları formun içine ekle
          const form = document.getElementById("spinForm");
          [iysType, isySource, iysStatus, iysRecipient, iysConsent].forEach(
            (input) => {
              input.style.display = "none"; // Gizle
              form.appendChild(input); // Form içerisine ekle
            }
          );
        }
        // Çark animasyonu
  
        const spinWheel = () => {
          const wheelElement = document.querySelector(".wheel");
          if (!wheelElement) {
            alert("Çark elementi bulunamadı!");
            return;
          }
          // Şans değerlerinin toplamını hesapla
          const totalChance = config.wheelData.reduce((sum, item) => {
            const chance = item.chance ? parseInt(item.chance) : 0;
            return sum + chance;
          }, 0);
  
          // Rastgele bir değer oluştur (0 ile toplam şans arasında)
          const randomValue = Math.random() * totalChance;
  
          let accumulatedChance = 0;
          let selectedIndex = -1;
  
          // Şans dağılımına göre uygun öğeyi seç
          for (let i = 0; i < config.wheelData.length; i++) {
            const chance = config.wheelData[i].chance
              ? parseInt(config.wheelData[i].chance)
              : 0;
            accumulatedChance += chance;
  
            if (randomValue <= accumulatedChance) {
              selectedIndex = i;
              break;
            }
          }
  
          // Seçilen öğeye göre dönüş açısını hesapla
          const rotation = -(360 * 3 + (360 / totalItems) * selectedIndex + 150);
  
          // Çark dönüş animasyonunu uygula
          wheelElement.style.transition = "transform 4s ease-out";
          wheelElement.style.transform = `rotate(${rotation}deg)`;
          saveSpinWheelActivity(2); //submit
          // Dönüş tamamlandıktan sonra sonucu göster
          setTimeout(() => {
            const winMessage = document.getElementById("winMessage");
            const winnerTitle = config.wheelData[selectedIndex].title;
            const winnerCode = config.wheelData[selectedIndex].code;
  
            // Kazanan başlığını ve kodunu ekle
            winMessage.innerHTML = `
              <p style="font-weight: bold; margin-bottom: 50px;">${decodeURIComponent(
                config.spinDesign.couponText
              )}</p>
              <p>${decodeURIComponent(winnerCode)}</p>
              <button id="copyButton" style="background-color: ${
                config.spinDesign.btnColor
              }; color: white; padding: 5px 10px; border: none; border-radius: 5px; cursor: pointer;">
                  Copy Code
              </button>
          `;
            winMessage.style.display = "block";
  
            // Kopyalama işlemi
            const copyButton = document.getElementById("copyButton");
            copyButton.addEventListener("click", () => {
              const textarea = document.createElement("textarea");
              textarea.value = winnerCode;
              document.body.appendChild(textarea);
              textarea.select();
              document.execCommand("copy");
              document.body.removeChild(textarea);
              alert("copy!");
            });
          }, 4000);
        };
  
        const integration = config.integration;
        // Form gönderimi
        const form = document.getElementById("spinForm");
  
        document
          .getElementById("spinForm")
          .addEventListener("submit", function (event) {
            event.preventDefault();
  
            const form = event.target; // Form nesnesini al
            const policyCheckbox = document.getElementById("policyCheckbox");
            const emailInput = document.querySelector(".emailSpin");
            const nameInput = document.querySelector(".nameSpin");
            const surnameInput = document.querySelector(".surnameSpin");
  
            let newErrors = {};
  
            document
              .querySelectorAll(".error-textSpin")
              .forEach((errorDiv) => (errorDiv.textContent = ""));
  
            if (
              config.spinDesign.policy === 1 &&
              policyCheckbox &&
              !policyCheckbox.checked
            ) {
              newErrors.privacyPolicy = decodeURIComponent(
                config.spinDesign.privacyAlert
              );
            }
            if (emailInput && !emailInput.value.trim()) {
              newErrors.email = decodeURIComponent(config.spinDesign.emailAlert);
            }
            if (nameInput && !nameInput.value.trim()) {
              newErrors.firstName = decodeURIComponent(
                config.spinDesign.nameAlert
              );
            }
            if (surnameInput && !surnameInput.value.trim()) {
              newErrors.lastName = decodeURIComponent(
                config.spinDesign.surnameAlert
              );
            }
  
            if (Object.keys(newErrors).length > 0) {
              if (newErrors.firstName)
                document.querySelector(".error-textSpin.firstName").textContent =
                  newErrors.firstName;
              if (newErrors.lastName)
                document.querySelector(".error-textSpin.lastName").textContent =
                  newErrors.lastName;
              if (newErrors.email)
                document.querySelector(".error-textSpin.email").textContent =
                  newErrors.email;
              if (newErrors.privacyPolicy)
                document.querySelector(
                  ".error-textSpin.privacyPolicy"
                ).textContent = newErrors.privacyPolicy;
              return;
            }
  
            spinWheel();
  
            const today = new Date();
            const formattedDate =
              today.getFullYear() +
              "-" +
              String(today.getMonth() + 1).padStart(2, "0") +
              "-" +
              String(today.getDate()).padStart(2, "0") +
              " " +
              String(today.getHours()).padStart(2, "0") +
              ":" +
              String(today.getMinutes()).padStart(2, "0") +
              ":" +
              String(today.getSeconds()).padStart(2, "0");
  
            const formData = new URLSearchParams();
            formData.append("confirmation_page", "tesekkurler.html");
            formData.append("my_form_id", config.integration);
            formData.append("rvs_in_optin_email", "1");
            formData.append("rvs_in_email", emailInput.value);
            formData.append("rvs_in_iys_type", "EPOSTA");
            formData.append("rvs_in_iys_type", "EPOSTA");
            formData.append("rvs_in_iys_source", "HS_WEB");
            formData.append("rvs_in_iys_source", "HS_WEB");
            formData.append("rvs_in_iys_status", "ONAY");
            formData.append("rvs_in_iys_status", "ONAY");
            formData.append("rvs_in_iys_recipient_type", "BIREYSEL");
            formData.append("rvs_in_iys_recipient_type", "BIREYSEL");
            formData.append("rvs_in_status_id", "110");
            formData.append("rvs_in_status_id", "");
            formData.append("rvs_in_pnmgiven", nameInput.value);
            formData.append("rvs_in_pnmfamily", surnameInput.value);
            formData.append("rvs_in_iys_consent_date", formattedDate);
            formData.append("popup-onay", "on");
  
            fetch("https://revoform.revotas.com/frm/sv/FormProcessor", {
              method: "POST",
              headers: {
                "Content-Type": "application/x-www-form-urlencoded",
                Accept: "application/json",
              },
              body: formData.toString(),
            })
              .then((response) => {
                if (!response.ok) {
                  throw new Error("Form gönderimi başarısız.");
                }
                return response.json();
              })
              .then((data) => {
                console.log("Form başarıyla gönderildi:", data);
              })
              .catch((error) => {
                console.error("Hata:", error);
              });
          });
  
        const style = document.createElement("style");
        style.innerHTML = `
              .container-rvtsSpinWheel {
                  background: ${
                    config.spinDesign.background
                      ? config.spinDesign.background
                      : "url('https://l2.revotas.com/js/revotas/spinwheel2/img/background.png') center/cover no-repeat"
                  };
                  border-radius: 7px;
                  border: 1px solid ${config.spinDesign.backgroundBorder};
                  padding: 30px;
                  display: flex;
                  overflow: hidden;
              }
              .error-textSpin{
                  color: red;
                  font-size: 11px;
                  margin-top: 10px;
                  margin-bottom:10px;
              }
              .form-container{
              margin-top: 10px;
              width: 400px;
              border-radius: 5px;
              margin-left: 50px;
              text-align: center;
              }
              #policyCheckbox {
              /* Varsayılan checkbox stilini kaldırıyoruz */
              appearance: none;
              width: 16px;
              height: 16px;
              border: 1px solid #898989;
              border-radius: 50%;
              cursor: pointer;
              position: relative;
          }
      
          /* Checkbox işaretlendiğinde içindeki nokta */
          #policyCheckbox:checked::before {
              content: '';
              position: absolute;
              top: 3px;
              left: 3px;
              width: 8px;
              height: 8px;
              border-radius: 50%;
              background-color: #000; /* Noktanın rengi */
          }
      
      
              @media (max-width: 768px) {
                  .container-rvtsSpinWheel {
                      flex-direction: column-reverse;
                      padding:9px;
                  }
                  .form-container{
                  margin-top: 10px;
                  width: 355px;
                  padding: 53px;
                  border-radius: 5px;
                  margin-left: 31px;
                  text-align: center;
                  }
                  .spin-wheel{    margin-bottom: -88px!important;}
              }
                  .fixed-box {
                  position: fixed;
                  z-index: 999;
                  border-radius: 7px;
                  transition: all 0.3s ease-in-out;
          @media (min-width: 769px) {
                  .spin-wheel{    margin-left: -100px!important;}
              }
      }`;
        styleTag.innerHTML = `
      /* Üst - Sol */
      .fixed-box.top-left {
          top: 0;
          left: 0;
      }
      
      /* Üst - Orta */
      .fixed-box.top-center {
          top: 0;
          left: 50%;
          transform: translateX(-50%);
      }
      
      /* Üst - Sağ */
      .fixed-box.top-right {
          top: 0;
          right: 0;
      }
      
      /* Orta - Sol */
      .fixed-box.center-left {
          top: 50%;
          left: 0;
          transform: translateY(-50%);
      }
      
      /* Orta - Orta */
      .fixed-box.center-center {
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
      }
      
      /* Orta - Sağ */
      .fixed-box.center-right {
          top: 50%;
          right: 0;
          transform: translateY(-50%);
      }
      
      /* Alt - Sol */
      .fixed-box.bottom-left {
          bottom: 0;
          left: 0;
      }
      
      /* Alt - Orta */
      .fixed-box.bottom-center {
          bottom: 0;
          left: 50%;
          transform: translateX(-50%);
      }
      
      /* Alt - Sağ */
      .fixed-box.bottom-right {
          bottom: 0;
          right: 0;
      }`;
        document.head.appendChild(style);
  
        let slices = document.querySelectorAll(".slice");
        slices.forEach((slice) => {
          slice.style.width = "50%";
          slice.style.transformOrigin = "100%";
          slice.style.textAlign = "center";
          slice.style.lineHeight = "150%";
          slice.style.fontWeight = "bold";
          slice.style.color = "white";
          slice.style.display = "flex";
          slice.style.justifyContent = "center";
          slice.style.alignItems = "center";
          slice.style.clipPath = "polygon(0% 30%, 100% 50%, 0% 100%)";
        });
      }
  
      function rvtsPages(config, custId, popupId, popupName, isLivePreview) {
        var actions = config.actions;
        var currentUrl = window.location.href.toLowerCase();
        var pagesUrl = decodeURIComponent(config.pagesUrl).toLowerCase();
        var pagesUrlRule = config.pagesUrlRule;
        if (
          (pagesUrlRule === "is" && pagesUrl !== currentUrl) ||
          (pagesUrlRule === "isnot" && pagesUrl === currentUrl) ||
          (pagesUrlRule === "includes" && !currentUrl.includes(pagesUrl)) ||
          (pagesUrlRule === "notincludes" && currentUrl.includes(pagesUrl))
        ) {
          return;
        }
        var elementList = [];
        actions.forEach((action) => {
          var selector = decodeURIComponent(action[0]);
          var insertPosition = decodeURIComponent(action[1]);
          var content = decodeURIComponent(action[2]);
          var selectedElement = document.querySelector(selector);
          if (selectedElement) {
            var template = document.createElement("template");
            template.innerHTML = content;
            var newElement = template.content.children[0];
            if (insertPosition === "replace") {
              selectedElement.parentElement.replaceChild(
                newElement,
                selectedElement
              );
            } else {
              selectedElement.insertAdjacentElement(insertPosition, newElement);
            }
            elementList.push(newElement);
            var elList = Array.from(
              newElement.querySelectorAll("[activity_type=click]")
            );
            if (newElement.getAttribute("activity_type") === "click")
              elList.push(newElement);
            elList.forEach((element) => {
              element.addEventListener("click", function () {
                if (!isLivePreview)
                  rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
              });
            });
          }
        });
        if (!isLivePreview)
          rvtsPushSmartWidgetActivity(null, popupId, popupName, 0);
        return elementList;
      }
  
      var CountDown = (function () {
        var countGeneralTimer = null;
  
        var countMinuteTimer = null;
  
        var countGenericTimer = null;
  
        return function CountDown(config, isPreview, custId, popupId, popupName) {
          config.cssTimer = decodeURIComponent(config.cssTimer);
          config.topColor = decodeURIComponent(config.topColor);
          config.bottomColor = decodeURIComponent(config.bottomColor);
          config.timerColor = decodeURIComponent(config.timerColor);
          config.transparent = decodeURIComponent(config.transparent);
          config.tarih_aralik = decodeURIComponent(config.tarih_aralik);
          config.message = decodeURIComponent(config.message);
          config.querySelector = decodeURIComponent(config.querySelector);
          config.insertPosition = decodeURIComponent(config.insertPosition);
          config.languageTimer = decodeURIComponent(config.languageTimer);
          config.daysTimer = decodeURIComponent(config.daysTimer);
  
          var style = document.createElement("style");
          style.innerHTML = config.cssTimer;
          document.head.appendChild(style);
  
          function CountTimer() {
            var transparentBackground = document.getElementById("transparent");
  
            var timerDiv = document.createElement("div");
            timerDiv.id = "rvts-timerDiv";
            timerDiv.classList.add("rvts-timerDiv");
            document.body.appendChild(timerDiv);
  
            var titleDiv = document.createElement("div");
            titleDiv.setAttribute("id", "rvts-titleLabel");
            titleDiv.classList.add("rvts-titleLabel");
            titleDiv.style.fontSize = config.messageFont + "px";
            titleDiv.innerHTML = config.message;
            timerDiv.appendChild(titleDiv);
  
            var timeDiv = document.createElement("div");
            timeDiv.setAttribute("id", "rvts-timeDiv");
            timeDiv.classList.add("rvts-timeDiv");
            timerDiv.appendChild(timeDiv);
  
            var daysDiv = document.createElement("div");
            daysDiv.id = "rvts-daysDiv";
            daysDiv.classList.add("rvts-daysDiv");
            daysDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
            daysDiv.style.width = parseInt(config.timerFont) + 30 + "px";
            daysDiv.style.height = "auto";
            timeDiv.appendChild(daysDiv);
  
            var daysTime = document.createElement("span");
            daysTime.id = "rvts-daysTime";
            daysTime.classList.add("rvts-daysTime");
            daysTime.style.fontSize = config.timerFont + "px";
            daysTime.style.color = config.timerColor;
            daysDiv.appendChild(daysTime);
  
            var daysText = document.createElement("span");
            daysText.id = "rvts-daysText";
            daysText.classList.add("rvts-daysText");
            daysText.style.color = config.timerColor;
            daysText.style.width = parseInt(config.timerFont) + 30 + "px";
            daysText.style.fontSize = config.timerFont / 2 + 3 + "px";
            daysDiv.appendChild(daysText);
  
            var hoursDiv = document.createElement("div");
            hoursDiv.id = "rvts-hoursDiv";
            hoursDiv.classList.add("rvts-hoursDiv");
            hoursDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
            hoursDiv.style.width = parseInt(config.timerFont) + 30 + "px";
            hoursDiv.style.height = "auto";
            timeDiv.appendChild(hoursDiv);
  
            var hoursTime = document.createElement("span");
            hoursTime.id = "rvts-hoursTime";
            hoursTime.classList.add("rvts-hoursTime");
            hoursTime.style.color = config.timerColor;
            hoursTime.style.fontSize = config.timerFont + "px";
            hoursDiv.appendChild(hoursTime);
  
            var hoursText = document.createElement("span");
            hoursText.id = "rvts-hoursText";
            hoursText.classList.add("rvts-hoursText");
            hoursText.style.color = config.timerColor;
            hoursText.style.fontSize = config.timerFont / 2 + 3 + "px";
            hoursText.style.width = parseInt(config.timerFont) + 30 + "px";
            hoursDiv.appendChild(hoursText);
  
            var minutesDiv = document.createElement("div");
            minutesDiv.id = "rvts-minutesDiv";
            minutesDiv.classList.add("rvts-minutesDiv");
            minutesDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
            minutesDiv.style.width = parseInt(config.timerFont) + 30 + "px";
            minutesDiv.style.height = "auto";
            timeDiv.appendChild(minutesDiv);
  
            var minutesTime = document.createElement("span");
            minutesTime.id = "rvts-minutesTime";
            minutesTime.classList.add("rvts-minutesTime");
            minutesTime.style.color = config.timerColor;
            minutesTime.style.fontSize = config.timerFont + "px";
            minutesDiv.appendChild(minutesTime);
  
            var minutesText = document.createElement("span");
            minutesText.id = "rvts-minutesText";
            minutesText.classList.add("rvts-minutesText");
            minutesText.style.color = config.timerColor;
            minutesText.style.fontSize = config.timerFont / 2 + 3 + "px";
            minutesText.style.width = parseInt(config.timerFont) + 30 + "px";
            minutesDiv.appendChild(minutesText);
  
            var secondsDiv = document.createElement("div");
            secondsDiv.id = "rvts-secondsDiv";
            secondsDiv.classList.add("rvts-secondsDiv");
            secondsDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
            secondsDiv.style.width = parseInt(config.timerFont) + 30 + "px";
            secondsDiv.style.height = "auto";
            timeDiv.appendChild(secondsDiv);
  
            var secondsTime = document.createElement("span");
            secondsTime.id = "rvts-secondsTime";
            secondsTime.classList.add("rvts-secondsTime");
            secondsTime.style.color = config.timerColor;
            secondsTime.style.fontSize = config.timerFont + "px";
            secondsDiv.appendChild(secondsTime);
  
            var secondsText = document.createElement("span");
            secondsText.id = "rvts-secondsText";
            secondsText.classList.add("rvts-secondsText");
            secondsText.style.color = config.timerColor;
            secondsText.style.fontSize = config.timerFont / 2 + 3 + "px";
            secondsText.style.width = parseInt(config.timerFont) + 30 + "px";
            secondsDiv.appendChild(secondsText);
  
            function Timer() {
              var endDate = config.tarih_aralik;
              var endMinute = config.minutes;
  
              clearInterval(countGeneralTimer);
              clearInterval(countMinuteTimer);
              clearInterval(countGenericTimer);
  
              countGeneralTimer = setInterval(() => {
                if (endDate || endMinute) {
                  clearInterval(countGeneralTimer);
                }
  
                function minuteTimer() {
                  if (
                    config.timerMinute == true &&
                    config.timerGeneric == false
                  ) {
                    clearInterval(countMinuteTimer);
  
                    countMinuteTimer = setInterval(() => {
                      var storageVal = localStorage.getItem("date");
  
                      if (JSON.parse(storageVal)) {
                        var endTimeMinutes =
                          JSON.parse(storageVal) + parseInt(endMinute) * 60000;
                        var timerLeft = Math.floor(
                          (endTimeMinutes - Date.now()) / 1000
                        );
                      } else {
                        var nowMinutes = new Date();
                        nowMinutes = Date.parse(nowMinutes);
                        var endTimeMinutes =
                          nowMinutes + parseInt(endMinute) * 60000;
                        var timerLeft = Math.floor(
                          (endTimeMinutes - Date.now()) / 1000
                        );
                        var localDate = localStorage.setItem(
                          "date",
                          JSON.stringify(Date.now())
                        );
                      }
  
                      if (timerLeft < 0) {
                        clearInterval(countMinuteTimer);
                      }
  
                      if (config.daysTimer == "include") {
                        var day = Math.floor(Math.abs(timerLeft) / 86400);
                        var hour = Math.floor(
                          (Math.abs(timerLeft) - day * 86400) / 3600
                        );
                        var minute = Math.floor(
                          (Math.abs(timerLeft) - day * 86400 - hour * 3600) / 60
                        );
                        var second = Math.floor(
                          Math.abs(timerLeft) -
                            day * 86400 -
                            hour * 3600 -
                            minute * 60
                        );
                        document.getElementById("rvts-daysDiv").style.display =
                          "";
                      } else if (config.daysTimer == "exclude") {
                        document.getElementById("rvts-daysTime").style.display =
                          "none";
                        document.getElementById("rvts-daysDiv").style.display =
                          "none";
                        var hour = Math.floor(Math.abs(timerLeft) / 3600);
                        var minute = Math.floor(
                          (Math.abs(timerLeft) - hour * 3600) / 60
                        );
                        var second = Math.floor(
                          Math.abs(timerLeft) - hour * 3600 - minute * 60
                        );
                      }
  
                      if (day < "10") {
                        day;
                      }
                      if (hour < "10") {
                        hour = "0" + hour;
                      }
                      if (minute < "10") {
                        minute = "0" + minute;
                      }
                      if (second < "10") {
                        second = "0" + second;
                      }
  
                      document.getElementById("rvts-daysTime").innerText = day;
                      document.getElementById("rvts-hoursTime").innerText = hour;
                      document.getElementById("rvts-minutesTime").innerText =
                        minute;
                      document.getElementById("rvts-secondsTime").innerText =
                        second;
  
                      if (config.timerText == true) {
                        if (config.languageTimer == "english") {
                          if (config.daysTimer == "include") {
                            document.getElementById("rvts-daysText").innerText =
                              "Days";
                          }
  
                          document.getElementById("rvts-hoursText").innerText =
                            "Hours";
                          document.getElementById("rvts-minutesText").innerText =
                            "Minutes";
                          document.getElementById("rvts-secondsText").innerText =
                            "Seconds";
                        } else if (config.languageTimer == "turkish") {
                          if (config.daysTimer == "include") {
                            document.getElementById("rvts-daysText").innerText =
                              "Gün";
                          }
  
                          document.getElementById("rvts-hoursText").innerText =
                            "Saat";
                          document.getElementById("rvts-minutesText").innerText =
                            "Dakika";
                          document.getElementById("rvts-secondsText").innerText =
                            "Saniye";
                        } else if (config.languageTimer == "spanish") {
                          if (config.daysTimer == "include") {
                            document.getElementById("rvts-daysText").innerText =
                              "Día";
                          }
  
                          document.getElementById("rvts-hoursText").innerText =
                            "Hora";
                          document.getElementById("rvts-minutesText").innerText =
                            "Minuto";
                          document.getElementById("rvts-secondsText").innerText =
                            "Segundo";
                        }
                      }
  
                      if (config.transparent == 1) {
                        daysDiv.style.background = "transparent";
                        hoursDiv.style.background = "transparent";
                        minutesDiv.style.background = "transparent";
                        secondsDiv.style.background = "transparent";
                      } else {
                        daysDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
                        hoursDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
                        minutesDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
                        secondsDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
                      }
  
                      if (timerLeft == 0) {
                        localStorage.removeItem("date");
                      }
  
                      if (config.timerStart == true && timerLeft == 0) {
                        repeat = setTimeout(function () {
                          minuteTimer();
                        }, 1000);
                      }
                    }, 0);
  
                    if (config.timerHide == true && timerLeft == 0) {
                      document.getElementById("rvts-timerDiv").style.display =
                        "none";
                    }
                  }
                }
  
                minuteTimer();
  
                function genericTimer() {
                  if (
                    config.timerGeneric == true &&
                    config.timerMinute == false
                  ) {
                    clearInterval(countGenericTimer);
  
                    countGenericTimer = setInterval(() => {
                      var endTime = new Date(endDate);
                      endTime = endTime / 1000;
                      var now = new Date();
                      now = now / 1000;
                      var timeLeft = endTime - now;
  
                      if (timeLeft < 0) {
                        clearInterval(countGenericTimer);
                      }
  
                      if (config.daysTimer == "include") {
                        var days = Math.floor(Math.abs(timeLeft) / 86400);
                        var hours = Math.floor(
                          (Math.abs(timeLeft) - days * 86400) / 3600
                        );
                        var minutes = Math.floor(
                          (Math.abs(timeLeft) - days * 86400 - hours * 3600) / 60
                        );
                        var seconds = Math.floor(
                          Math.abs(timeLeft) -
                            days * 86400 -
                            hours * 3600 -
                            minutes * 60
                        );
  
                        document.getElementById("rvts-daysDiv").style.display =
                          "";
                      } else if (config.daysTimer == "exclude") {
                        document.getElementById("rvts-daysTime").style.display =
                          "none";
                        document.getElementById("rvts-daysDiv").style.display =
                          "none";
  
                        var hours = Math.floor(Math.abs(timeLeft) / 3600);
                        var minutes = Math.floor(Math.abs(timeLeft / 60) % 60);
                        var seconds = Math.floor(Math.abs(timeLeft) % 60);
                      }
  
                      if (days < "10") {
                        days;
                      }
                      if (hours < "10") {
                        hours = "0" + hours;
                      }
                      if (minutes < "10") {
                        minutes = "0" + minutes;
                      }
                      if (seconds < "10") {
                        seconds = "0" + seconds;
                      }
  
                      document.getElementById("rvts-daysTime").innerText = days;
                      document.getElementById("rvts-hoursTime").innerText = hours;
                      document.getElementById("rvts-minutesTime").innerText =
                        minutes;
                      document.getElementById("rvts-secondsTime").innerText =
                        seconds;
  
                      if (config.timerText == true) {
                        if (config.languageTimer == "english") {
                          if (config.daysTimer == "include") {
                            document.getElementById("rvts-daysText").innerText =
                              "Days";
                          }
  
                          document.getElementById("rvts-hoursText").innerText =
                            "Hours";
                          document.getElementById("rvts-minutesText").innerText =
                            "Minutes";
                          document.getElementById("rvts-secondsText").innerText =
                            "Seconds";
                        } else if (config.languageTimer == "turkish") {
                          if (config.daysTimer == "include") {
                            document.getElementById("rvts-daysText").innerText =
                              "Gün";
                          }
  
                          document.getElementById("rvts-hoursText").innerText =
                            "Saat";
                          document.getElementById("rvts-minutesText").innerText =
                            "Dakika";
                          document.getElementById("rvts-secondsText").innerText =
                            "Saniye";
                        } else if (config.languageTimer == "spanish") {
                          if (config.daysTimer == "include") {
                            document.getElementById("rvts-daysText").innerText =
                              "Día";
                          }
  
                          document.getElementById("rvts-hoursText").innerText =
                            "Hora";
                          document.getElementById("rvts-minutesText").innerText =
                            "Minuto";
                          document.getElementById("rvts-secondsText").innerText =
                            "Segundo";
                        }
                      }
  
                      if (config.transparent == 1) {
                        daysDiv.style.background = "transparent";
                        hoursDiv.style.background = "transparent";
                        minutesDiv.style.background = "transparent";
                        secondsDiv.style.background = "transparent";
                      } else {
                        daysDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
                        hoursDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
                        minutesDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
                        secondsDiv.style.background = `linear-gradient(${config.topColor}, ${config.bottomColor})`;
                      }
  
                      if (timeLeft == 0) {
                        document.getElementById("rvts-timerDiv").style.display =
                          "none";
                      }
                    }, 0);
                  }
                }
  
                genericTimer();
              }, 0);
            }
  
            Timer();
  
            return timerDiv;
          }
  
          var countDiv = CountTimer();
  
          if (!isPreview) {
            // View event'ini kaydet
            var fetchParams =
              "cust_id=" +
              custId +
              "&popup_id=" +
              popupId +
              "&form_id=0&user_agent=" +
              navigator.userAgent +
              "&activity_type=0" +
              "&session_id=" +
              rvtsSessionId;
            if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
            if (/Mobi|Android/i.test(navigator.userAgent)) {
              fetchParams += "&device=" + "1"; // mobile
            } else {
              fetchParams += "&device=" + "2"; // desktop
            }
            fetchParams +=
              "&url=" +
              window.location.href.split("&").join(encodeURIComponent("&"));
            fetch(
              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                fetchParams
            );
            rvtsPushGaEvent(0, popupName);
          }
  
          // Click event'lerini ekle - countdown'da tıklanabilir elementler varsa
          var clickableElements = document.querySelectorAll("#rvts-timerDiv");
          clickableElements.forEach(function (element) {
            element.addEventListener("click", function () {
              if (!isPreview) {
                // Click event'ini kaydet
                var fetchParams =
                  "cust_id=" +
                  custId +
                  "&popup_id=" +
                  popupId +
                  "&form_id=0&user_agent=" +
                  navigator.userAgent +
                  "&activity_type=1" +
                  "&session_id=" +
                  rvtsSessionId;
                if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
                if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
                if (/Mobi|Android/i.test(navigator.userAgent)) {
                  fetchParams += "&device=" + "1"; // mobile
                } else {
                  fetchParams += "&device=" + "2"; // desktop
                }
                fetchParams +=
                  "&url=" +
                  window.location.href.split("&").join(encodeURIComponent("&"));
                fetch(
                  "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                    fetchParams
                );
                rvtsPushGaEvent(1, popupName);
                saveSwSource(popupId);
              }
            });
          });
  
          if (!isPreview) {
            var selectedElement = document.querySelector(config.querySelector);
  
            if (config.insertPosition === "replace") {
              selectedElement.parentElement.replaceChild(
                countDiv,
                selectedElement
              );
            } else {
              selectedElement.insertAdjacentElement(
                config.insertPosition,
                countDiv
              );
            }
          } else {
            return countDiv;
          }
        };
      })();
  
      async function notificationCenter(
        config,
        custId,
        popupId,
        popupName,
        isLivePreview
      ) {
        config.cssCode = decodeURIComponent(config.cssCode);
        config.title = decodeURIComponent(config.title);
        config.image = decodeURIComponent(config.image);
        config.notificationLinkList = config.notificationLinkList.map((e) =>
          decodeURIComponent(e)
        );
        config.notificationTextList = config.notificationTextList.map((e) =>
          decodeURIComponent(e)
        );
        config.notificationImageList = config.notificationImageList.map((e) =>
          decodeURIComponent(e)
        );
        var style = document.createElement("style");
  
        style.innerHTML = config.cssCode;
  
        function saveNotificationCenterActivity(actType) {
          if (!isLivePreview) {
            var fetchParams =
              "cust_id=" +
              custId +
              "&popup_id=" +
              popupId +
              "&form_id=0&user_agent=" +
              navigator.userAgent +
              "&activity_type=" +
              actType +
              "&session_id=" +
              rvtsSessionId;
            if (rvtsUserId) fetchParams += "&user_id=" + rvtsUserId;
            if (rvtsEmail) fetchParams += "&email=" + rvtsEmail;
            fetchParams +=
              "&url=" +
              window.location.href.split("&").join(encodeURIComponent("&"));
            if (/Mobi|Android/i.test(navigator.userAgent)) {
              fetchParams += "&device=" + "1";
            } else {
              fetchParams += "&device=" + "2";
            }
            fetch(
              "https://f.revotas.com/frm/smartwidgets/save_smartwidget_activity.jsp?" +
                fetchParams
            );
            if (actType == 1) saveSwSource(popupId);
            rvtsPushGaEvent(actType, popupName);
          }
        }
  
        document.head.appendChild(style);
        function Bell() {
          var value = config.image.length;
          if (value > 0) {
            var div = document.createElement("div");
            div.setAttribute("id", "rvts-imageDiv");
            div.classList.add("rvts-notification-imageDiv");
            document.body.appendChild(div);
  
            var img = document.createElement("img");
            img.src = config.image;
            img.classList.add("rvts-notification-image");
            div.appendChild(img);
  
            var labelNumber = document.createElement("label");
            labelNumber.innerText = config.notificationLinkList.length;
            labelNumber.setAttribute("id", "rvts-number");
            labelNumber.classList.add("rvts-notification-imageNumber");
            div.appendChild(labelNumber);
  
            if (config.showNumber == true) {
              labelNumber.style.display = "block";
            } else {
              labelNumber.style.display = "none";
            }
            return div;
          } else {
            var svg = document.createElement("svg");
            svg.classList.add("rvts-notification-bell");
            svg.setAttribute("id", "rvts-svgId");
            svg.innerHTML =
              '<svg left="8px" viewBox="0 0 16 16"  class="bi bi-bell-fill bell ring" fill="currentColor" xmlns="http://www.w3.org/2000/svg"> <path d="M8 16a2 2 0 0 0 2-2H6a2 2 0 0 0 2 2zm.995-14.901a1 1 0 1 0-1.99 0A5.002 5.002 0 0 0 3 6c0 1.098-.5 6-2 7h14c-1.5-1-2-5.902-2-7 0-2.42-1.72-4.44-4.005-4.901z"/> </svg>';
  
            var label = document.createElement("label");
            label.innerText = config.notificationLinkList.length;
            label.setAttribute("id", "rvts-numberId");
            label.classList.add("rvts-notification-labelNumber");
            svg.appendChild(label);
            if (config.showNumber == true) {
              label.style.display = "block";
            } else {
              label.style.display = "none";
            }
            return svg;
          }
        }
  
        function OpportunityAlert() {
          var div = document.createElement("div");
          div.classList.add("rvts-notification-alertDiv");
          document.body.appendChild(div);
  
          var h3 = document.createElement("h3");
          h3.classList.add("rvts-notification-title");
          h3.appendChild(document.createTextNode(config.title));
          div.appendChild(h3);
  
          var ul = document.createElement("ul");
          ul.classList.add("rvts-notification-ul");
          for (var i = 0; i < config.notificationLinkList.length; i++) {
            let li = document.createElement("li");
            li.classList.add("rvts-notification-link");
  
            li.innerHTML =
              "<a class='rvts-link-text' href='" +
              config.notificationLinkList[i] +
              "'>" +
              config.notificationTextList[i] +
              "</a>";
            ul.appendChild(li);
  
            if (config.notificationImageList[i].length > 0) {
              var img = document.createElement("img");
              img.src = config.notificationImageList[i];
              img.classList.add("rvts-notification-linkimage");
              li.appendChild(img);
            }
          }
          div.appendChild(ul);
          return div;
        }
  
        var bellDiv = Bell();
        var rvtsAlertDiv = OpportunityAlert();
        rvtsAlertDiv.style.display = "none";
  
        var selectedElement = document.querySelector(config.querySelector);
        if (config.insertPosition === "replace") {
          selectedElement.parentElement.replaceChild(bellDiv, selectedElement);
        } else {
          selectedElement.insertAdjacentElement(config.insertPosition, bellDiv);
        }
        document.body.appendChild(rvtsAlertDiv);
  
        var rvtsAlertTimeout = null;
  
        function getScrollTop() {
          var h = document.documentElement,
            b = document.body,
            st = "scrollTop",
            sh = "scrollHeight";
          return h[st] || b[st];
        }
  
        var isMobile = __smartWidgetConditionFunctions__.deviceType("mobile");
  
        if (isMobile) {
          var isOpen = true;
          bellDiv.addEventListener("click", function () {
            var clientRect = this.getBoundingClientRect();
            rvtsAlertDiv.style.top = clientRect.bottom + 16 + "px";
            rvtsAlertDiv.style.right = clientRect.right - 143 + "px";
            if (isOpen) {
              rvtsAlertDiv.style.display = "";
              isOpen = false;
            } else {
              rvtsAlertDiv.style.display = "none";
              isOpen = true;
            }
            saveNotificationCenterActivity(1);
          });
          document.addEventListener("scroll", function () {
            var clientRect = bellDiv.getBoundingClientRect();
            rvtsAlertDiv.style.top =
              clientRect.bottom + getScrollTop() + 16 + "px";
            rvtsAlertDiv.style.right = clientRect.right - 143 + "px";
          });
        } else {
          bellDiv.addEventListener("mouseenter", function () {
            var clientRect = this.getBoundingClientRect();
            rvtsAlertDiv.style.top = clientRect.bottom + 15 + "px";
            rvtsAlertDiv.style.left = clientRect.left - 87 + "px";
            rvtsAlertDiv.style.display = "";
          });
  
          bellDiv.addEventListener("mouseleave", function (e) {
            clearTimeout(rvtsAlertTimeout);
            rvtsAlertTimeout = setTimeout(function () {
              rvtsAlertDiv.style.display = "none";
            }, 500);
          });
  
          rvtsAlertDiv.addEventListener("mouseenter", function () {
            clearTimeout(rvtsAlertTimeout);
            this.style.display = "";
          });
  
          rvtsAlertDiv.addEventListener("mouseleave", function () {
            clearTimeout(rvtsAlertTimeout);
            rvtsAlertTimeout = setTimeout(() => {
              this.style.display = "none";
            }, 500);
          });
  
          document.addEventListener("scroll", function () {
            var clientRect = bellDiv.getBoundingClientRect();
            rvtsAlertDiv.style.top =
              clientRect.bottom + getScrollTop() + 15 + "px";
            rvtsAlertDiv.style.left = clientRect.left - 87 + "px";
          });
        }
  
        saveNotificationCenterActivity(0);
  
        return {
          bell: bellDiv,
          list: rvtsAlertDiv,
        };
      }
  
      function dealsDiscovery(config, popupId, popupName) {
        config.cssDiscovery = decodeURIComponent(config.cssDiscovery);
        config.name = decodeURIComponent(config.name);
        config.number = decodeURIComponent(config.number);
        config.iframe = decodeURIComponent(config.iframe);
        config.discoveryLinkList = config.discoveryLinkList.map((e) =>
          decodeURIComponent(e)
        );
        config.discoveryTitleList = config.discoveryTitleList.map((e) =>
          decodeURIComponent(e)
        );
        config.discoveryTextList = config.discoveryTextList.map((e) =>
          decodeURIComponent(e)
        );
        config.discoveryImageList = config.discoveryImageList.map((e) =>
          decodeURIComponent(e)
        );
        config.discoveryDealsTitleList = config.discoveryDealsTitleList.map((e) =>
          decodeURIComponent(e)
        );
        config.discoveryDealsTextList = config.discoveryDealsTextList.map((e) =>
          decodeURIComponent(e)
        );
        config.discoveryDealsImageList = config.discoveryDealsImageList.map((e) =>
          decodeURIComponent(e)
        );
        config.discoveryDealNameList = config.discoveryDealNameList.map((e) =>
          decodeURIComponent(e)
        );
        config.discoveryHtmlList = config.discoveryHtmlList.map((e) =>
          decodeURIComponent(e)
        );
  
        var style = document.createElement("style");
        style.innerHTML = config.cssDiscovery;
        document.head.appendChild(style);
        function Widget() {
          var Div = document.createElement("div");
          Div.classList.add("rvts-discovery-widget");
          Div.setAttribute("id", "rvts-Div");
          document.body.appendChild(Div);
  
          var svg = document.createElement("svg");
          svg.setAttribute("id", "rvts-svgId");
          svg.classList.add("rvts-discovery-svg");
          svg.innerHTML =
            '<svg xmlns="http://www.w3.org/2000/svg" width="48px" height="48px" fill="white" class="bi bi-lightning" viewBox="0 0 16 16"><path d="M11.251.068a.5.5 0 0 1 .227.58L9.677 6.5H13a.5.5 0 0 1 .364.843l-8 8.5a.5.5 0 0 1-.842-.49L6.323 9.5H3a.5.5 0 0 1-.364-.843l8-8.5a.5.5 0 0 1 .615-.09zM4.157 8.5H7a.5.5 0 0 1 .478.647L6.11 13.59l5.732-6.09H9a.5.5 0 0 1-.478-.647L9.89 2.41 4.157 8.5z"/></svg>';
          Div.appendChild(svg);
  
          var label = document.createElement("label");
          label.innerText = config.number;
          label.setAttribute("id", "rvts-number");
          label.classList.add("rvts-discovery-label");
          svg.appendChild(label);
          rvtsPushSmartWidgetActivity(null, popupId, popupName, 0);
  
          return Div;
        }
        function Box() {
          var Div = document.createElement("div");
          Div.classList.add("rvts-discovery-box");
          document.body.appendChild(Div);
  
          var newDiv = document.createElement("div");
          newDiv.classList.add("rvts-discovery-header");
          newDiv.setAttribute("id", "rvts-header");
          Div.appendChild(newDiv);
  
          var label = document.createElement("label");
          label.classList.add("rvts-discovery-boxLabel");
          label.innerHTML = config.name;
          newDiv.appendChild(label);
  
          var svg = document.createElement("svg");
          svg.setAttribute("id", "rvts-closed");
          svg.classList.add("rvts-discovery-boxSvg");
          svg.innerHTML =
            '<svg width="48px" height="42px" viewBox="0 0 16 16" class="bi bi-x" color="white" fill="currentColor" xmlns="http://www.w3.org/2000/svg"> <path fill-rule="evenodd" d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/> </svg>';
          newDiv.appendChild(svg);
  
          var newDiv2 = document.createElement("div");
          newDiv2.classList.add("rvts-discovery-card");
          newDiv2.setAttribute("id", "rvts-card");
          Div.appendChild(newDiv2);
  
          config.discoveryLinkList.forEach((e, index) => {
            var div = document.createElement("div");
            div.setAttribute("id", "rvts-linkDiv");
            div.classList.add("rvts-discovery-linkDiv");
            newDiv2.appendChild(div);
            var link = document.createElement("a");
            link.classList.add("rvts-discovery-link");
            link.href = config.discoveryLinkList[index];
            div.appendChild(link);
            var img = document.createElement("img");
            img.classList.add("rvts-discovery-linkImg");
            img.src = config.discoveryImageList[index];
            link.appendChild(img);
            var h3 = document.createElement("h3");
            h3.classList.add("rvts-discovery-linkTitle");
            h3.innerHTML = config.discoveryTitleList[index];
            link.appendChild(h3);
            var label = document.createElement("label");
            label.classList.add("rvts-discovery-linkLabel");
            label.innerHTML = config.discoveryDealsTextList[index];
            link.appendChild(label);
          });
  
          config.discoveryDealsTitleList.forEach((e, index) => {
            var div = document.createElement("div");
            div.classList.add("rvts-discovery-textDiv");
            div.setAttribute("id", "rvts-textDiv");
            newDiv2.appendChild(div);
            var img = document.createElement("img");
            img.classList.add("rvts-discovery-textImg");
            img.src = config.discoveryDealsImageList[index];
            div.appendChild(img);
            var h3 = document.createElement("h3");
            h3.classList.add("rvts-discovery-textTitle");
            h3.innerHTML = config.discoveryDealsTitleList[index];
            div.appendChild(h3);
            var label = document.createElement("label");
            label.classList.add("rvts-discovery-textLabel");
            label.innerHTML = config.discoveryDealsTextList[index];
            div.appendChild(label);
          });
  
          config.discoveryHtmlList.forEach((e, index) => {
            var contentDiv = document.createElement("div");
            contentDiv.setAttribute("id", "rvts-content");
            contentDiv.classList.add("rvts-discovery-dealContent");
            contentDiv.innerHTML = config.discoveryHtmlList[index];
            Div.appendChild(contentDiv);
            var newDiv = document.createElement("div");
            newDiv.setAttribute("id", "rvts-header-content");
            newDiv.classList.add("rvts-discovery-headerContent");
            contentDiv.appendChild(newDiv);
            var label = document.createElement("label");
            label.classList.add("rvts-discovery-headerLabel");
            label.innerHTML = config.name;
            newDiv.appendChild(label);
            var svg = document.createElement("svg");
            svg.setAttribute("id", "rvts-closed-content");
            svg.classList.add("rvts-discovery-closedContent");
            svg.innerHTML =
              '<svg viewBox="0 0 16 16" class="bi bi-x" fill="currentColor" xmlns="http://www.w3.org/2000/svg"> <path fill-rule="evenodd" d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/> </svg>';
            newDiv.appendChild(svg);
            var backSvg = document.createElement("svg");
            backSvg.setAttribute("id", "rvts-arrowLeft");
            backSvg.classList.add("rvts-discovery-arrowLeft");
            backSvg.innerHTML =
              '<svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" class="bi bi-arrow-left" viewBox="0 0 16 16"><path fill-rule="evenodd" d="M15 8a.5.5 0 0 0-.5-.5H2.707l3.147-3.146a.5.5 0 1 0-.708-.708l-4 4a.5.5 0 0 0 0 .708l4 4a.5.5 0 0 0 .708-.708L2.707 8.5H14.5A.5.5 0 0 0 15 8z"/></svg> ';
            newDiv.appendChild(backSvg);
          });
  
          document.querySelectorAll("#rvts-textDiv").forEach(function (t, index) {
            t.addEventListener("click", function () {
              document.getElementById("rvts-card").style.display = "none";
              document.getElementById("rvts-iframeDiv").style.display = "none";
              document.getElementById("rvts-header").style.display = "none";
              document.querySelectorAll("#rvts-content")[index].style.left =
                "0px";
              rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
            });
            document
              .querySelectorAll("#rvts-arrowLeft")
              .forEach(function (t, index) {
                t.addEventListener("click", function () {
                  document.getElementById("rvts-card").style.display = "";
                  document.getElementById("rvts-iframeDiv").style.display = "";
                  document.getElementById("rvts-header").style.display = "";
                  document.querySelectorAll("#rvts-content")[index].style.left =
                    "-100%";
                  rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
                });
              });
          });
          var clientRect = document
            .getElementById("rvts-card")
            .getBoundingClientRect();
          var iframeDiv = document.createElement("div");
          iframeDiv.setAttribute("id", "rvts-iframeDiv");
          Div.appendChild(iframeDiv);
  
          var iframe = document.createElement("iframe");
          iframe.classList.add("rvts-discovery-iframe");
          iframe.src = config.iframe;
          iframe.style.top = clientRect.bottom + 15 + "px";
          iframe.setAttribute("allowFullScreen", "");
          iframeDiv.appendChild(iframe);
          return Div;
        }
        var rvtsWidget = Widget();
        var rvtsBox = Box();
        rvtsBox.style.display = "none";
  
        document.body.appendChild(rvtsWidget);
        document.body.appendChild(rvtsBox);
  
        rvtsWidget.addEventListener("click", function () {
          rvtsBox.style.display = "";
          rvtsWidget.style.display = "none";
          rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
        });
  
        document
          .getElementById("rvts-closed")
          .addEventListener("click", function () {
            rvtsBox.style.display = "none";
            rvtsWidget.style.display = "";
            rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
          });
  
        document
          .querySelectorAll("#rvts-closed-content")
          .forEach(function (t, index) {
            t.addEventListener("click", function () {
              document.querySelectorAll("#rvts-content")[index].style.left =
                "-100%";
              rvtsBox.style.display = "none";
              document.getElementById("rvts-card").style.display = "";
              document.getElementById("rvts-iframeDiv").style.display = "";
              document.getElementById("rvts-header").style.display = "";
              rvtsWidget.style.display = "";
              rvtsPushSmartWidgetActivity(null, popupId, popupName, 1);
            });
          });
      }
  
      if (document.querySelector(".rvts-discovery-box"))
        document.querySelector(".rvts-discovery-box").classList.add("ql-editor");
      document.querySelectorAll("#rvts-content").forEach((item) => {
        item.firstElementChild.style.marginTop = "60px";
      });
  
      var quilLink = document.createElement("link");
      quilLink.rel = "stylesheet";
      quilLink.href = "https://cdn.quilljs.com/1.3.6/quill.snow.css";
      document.head.append(quilLink);
  
      __smartWidgetConditionFunctions__.cookieValue = function cookieValue(
        cookieName,
        operator,
        value
      ) {
        var cookieContent = swGetCookie(cookieName);
        if (cookieContent == null) cookieContent = "";
        cookieContent = cookieContent.toLowerCase();
        if (operator === "is") {
          return cookieContent === value.toLowerCase();
        } else if (operator === "isnot") {
          return cookieContent !== value.toLowerCase();
        } else if (operator === "includes") {
          return cookieContent.includes(value.toLowerCase());
        } else if (operator === "notincludes") {
          return !cookieContent.includes(value.toLowerCase());
        }
      };
  
      __smartWidgetConditionFunctions__.deviceType = function deviceType(type) {
        const toMatch = [
          /Android/i,
          /webOS/i,
          /iPhone/i,
          /iPad/i,
          /iPod/i,
          /BlackBerry/i,
          /Windows Phone/i,
        ];
  
        var result = toMatch.some((toMatchItem) => {
          return navigator.userAgent.match(toMatchItem);
        });
  
        if (type === "mobile") {
          return result;
        } else if (type === "desktop") {
          return !result;
        }
      };
  
      __smartWidgetConditionFunctions__.pageType = function pageType(
        operator,
        type
      ) {
        if (typeof PAGE_TYPE === "undefined") return false;
        return PAGE_TYPE === type ? operator === "is" : operator === "isnot";
      };
  
      __smartWidgetConditionFunctions__.searchKeyword = function searchKeyword(
        operator,
        searchWord
      ) {
        var cname = "rvts_ps_search_list";
        var searchKeywordHistory = localStorage.getItem(cname);
        if (searchKeywordHistory) {
          var historyArray = JSON.parse(searchKeywordHistory).map((e) =>
            decodeURIComponent(e)
          );
          var tempArray = historyArray.filter(function (element) {
            if (operator === "is") {
              return element === searchWord.toLowerCase();
            } else if (operator === "isnot") {
              return element !== searchWord.toLowerCase();
            } else if (operator === "includes") {
              return element.includes(searchWord.toLowerCase());
            } else if (operator === "notincludes") {
              return !element.includes(searchWord.toLowerCase());
            }
          });
          if (operator === "is" || operator === "includes")
            return tempArray.length === 0 ? false : true;
          else if (operator === "isnot" || operator === "notincludes")
            return tempArray.length !== historyArray.length ? false : true;
        }
        return false;
      };
  
      __smartWidgetConditionFunctions__.pageUrl = function pageUrl(
        operator,
        url
      ) {
        var currentUrl = window.location.href.toLowerCase();
        if (operator === "is") {
          return currentUrl === url.toLowerCase();
        } else if (operator === "isnot") {
          return currentUrl !== url.toLowerCase();
        } else if (operator === "includes") {
          return currentUrl.includes(url.toLowerCase());
        } else if (operator === "notincludes") {
          return !currentUrl.includes(url.toLowerCase());
        }
      };
  
      __smartWidgetConditionFunctions__.pageUrlVisited = function pageUrlVisited(
        operator,
        url
      ) {
        var cname = "rvts_user_history_array";
        var storageVisitHistory = localStorage.getItem(cname);
        if (storageVisitHistory) {
          var historyArray = storageVisitHistory.split("|");
          var tempArray = historyArray.filter(function (element) {
            if (operator === "is") {
              return element === url.toLowerCase();
            } else if (operator === "isnot") {
              return element !== url.toLowerCase();
            } else if (operator === "includes") {
              return element.includes(url.toLowerCase());
            } else if (operator === "notincludes") {
              return !element.includes(url.toLowerCase());
            }
          });
          if (operator === "is" || operator === "includes")
            return tempArray.length === 0 ? false : true;
          else if (operator === "isnot" || operator === "notincludes")
            return tempArray.length !== historyArray.length ? false : true;
        }
        return false;
      };
  
      __smartWidgetConditionFunctions__.pageUrlVisitedDay =
        function pageUrlVisitedDay(operator, dayCount, url) {
          var cname = "rvts_user_history_array_date";
          var storageVisitHistory = localStorage.getItem(cname);
          if (storageVisitHistory) {
            var historyArray = JSON.parse(storageVisitHistory);
            historyArray = historyArray.filter(function (element) {
              var urlDate = new Date(element.date);
              var now = new Date();
              var timeDiff = Math.round(
                (now.getTime() - urlDate.getTime()) / (1000 * 60 * 60)
              );
              return timeDiff < dayCount * 24;
            });
            var tempArray = historyArray.filter(function (element) {
              if (operator === "is") {
                return element.link === url.toLowerCase();
              } else if (operator === "isnot") {
                return element.link !== url.toLowerCase();
              } else if (operator === "includes") {
                return element.link.includes(url.toLowerCase());
              } else if (operator === "notincludes") {
                return !element.link.includes(url.toLowerCase());
              }
            });
            if (operator === "is" || operator === "includes")
              return tempArray.length === 0 ? false : true;
            else if (operator === "isnot" || operator === "notincludes")
              return tempArray.length !== historyArray.length ? false : true;
          }
          return false;
        };
  
      __smartWidgetConditionFunctions__.timeSpent = function timeSpent(
        type,
        time
      ) {
        var cname = "rvts_user_browse_time";
        var cookieTimeSpent = swGetCookie(cname);
        if (cookieTimeSpent) {
          if (cookieTimeSpent >= time * (type === "minutes" ? 60 : 1)) {
            swSetCookie(cname, "0", 10, hname);
            return true;
          } else return false;
        }
        return false;
      };
  
      __smartWidgetConditionFunctions__.lastPopupShow = function lastPopupShow(
        days,
        pagesObj,
        popupId
      ) {
        var cname = "rvts_popup_last_show";
        var cookieLastShow = swGetCookie(cname);
        if (cookieLastShow) {
          try {
            obj = JSON.parse(cookieLastShow);
            if (!obj[popupId]) return true;
            var cookieDate = new Date(obj[popupId]);
            cookieDate.setHours(23, 59, 59, 999);
            var cDate = new Date();
            cDate.setHours(23, 59, 59, 999);
            var dayDiff = Math.ceil((cDate - cookieDate) / (1000 * 60 * 60 * 24));
            if (dayDiff >= days) return true;
            else return false;
          } catch (e) {
            return true;
          }
        }
        return true;
      };
  
      __smartWidgetConditionFunctions__.firstVisit = function firstVisit() {
        var cname = "rvts_user_first_visit";
        if (swGetCookie(cname)) {
          return false;
        } else {
          swSetCookie(cname, "0", 1000, hname);
          return true;
        }
      };
  
      __smartWidgetConditionFunctions__.returningUser = function returningUser() {
        var cname = "rvts_user_first_visit";
        if (swGetCookie(cname)) {
          return true;
        } else {
          swSetCookie(cname, "0", 1000, hname);
          return false;
        }
      };
  
      __smartWidgetConditionFunctions__.gender = function gender(type) {
        if (typeof MEMBER_INFO === "undefined" || MEMBER_INFO.ID == 0)
          return false;
        return (
          (MEMBER_INFO.GENDER == "E" && type == "male") ||
          (MEMBER_INFO.GENDER == "K" && type == "female")
        );
      };
  
      __smartWidgetConditionFunctions__.loggedIn = function loggedIn(operator) {
        if (typeof MEMBER_INFO === "undefined") return false;
        if (MEMBER_INFO.ID == 0) {
          return operator === "isnot";
        } else {
          return operator === "is";
        }
      };
  
      __smartWidgetConditionFunctions__.isMember = function isMember(
        is,
        pagesObj
      ) {
        var currentUrl = window.location.href.toLowerCase();
        var registerPage = pagesObj.registerPage;
        var cname = "rvts_is_member";
        var cookieIsMember = swGetCookie(cname);
        var pageUrlVisited = __smartWidgetConditionFunctions__.pageUrlVisited;
        if (cookieIsMember) {
          if (cookieIsMember == 1) {
            return is === "is" ? true : false;
          }
          return is === "is" ? false : true;
        } else {
          if (window["RvstData"]) {
            var status = RvstData.isMember;
            if (status == 1) {
              swSetCookie(cname, status, 10, hname);
              return is === "is" ? true : false;
            }
          } else {
            var registerPageArray = registerPage.split(",");
            for (var i = 0; i < registerPageArray.length; i++) {
              if (!registerPageArray[i].trim()) continue;
              if (
                currentUrl.includes(registerPageArray[i].toLowerCase()) ||
                pageUrlVisited("includes", registerPageArray[i].toLowerCase())
              ) {
                swSetCookie(cname, "1", 10, hname);
                return is === "is" ? true : false;
              }
            }
          }
        }
        return is === "is" ? false : true;
      };
  
      __smartWidgetConditionFunctions__.isSubscribed = function isSubscribed(
        is,
        pagesObj,
        popupId,
        widgetConfig
      ) {
        var isSubscribed = localStorage.getItem("subscribed_" + popupId);
        if (is === "is") {
          return isSubscribed == 1;
        } else if (is === "isnot") {
          return isSubscribed != 1;
        }
      };
  
      __smartWidgetConditionFunctions__.addedToCart = function addedToCart(
        is,
        pagesObj
      ) {
        var currentUrl = window.location.href.toLowerCase();
        var cartPage = pagesObj.cartPage;
        var pageUrlVisited = __smartWidgetConditionFunctions__.pageUrlVisited;
        var resolver = null;
        var promise = new Promise((resolve, reject) => {
          resolver = resolve;
        });
        function checkCart() {
          if (window["memberCart"]) {
            var status = memberCart.pCount > 0 ? 1 : 0;
            if (status == 1) {
              resolver(is === "is" ? true : false);
            }
          } else if (window["rvtsCart"]) {
            var status = rvtsCart.count > 0 ? 1 : 0;
            if (status == 1) {
              resolver(is === "is" ? true : false);
            }
          } else {
            var cartPageArray = cartPage.split(",");
            for (var i = 0; i < cartPageArray.length; i++) {
              if (!cartPageArray[i].trim()) continue;
              if (
                currentUrl.includes(cartPageArray[i].toLowerCase()) ||
                pageUrlVisited("includes", cartPageArray[i].toLowerCase())
              ) {
                resolver(is === "is" ? true : false);
              }
            }
          }
          resolver(is === "is" ? false : true);
        }
        if (document.readyState === "complete") checkCart();
        else window.addEventListener("load", checkCart);
        return promise;
      };
  
      __smartWidgetConditionFunctions__.userOrdered = function userOrdered(
        is,
        pagesObj
      ) {
        var currentUrl = window.location.href.toLowerCase();
        var orderPage = pagesObj.orderPage;
        var cname = "rvts_user_ordered";
        var cookieUserOrdered = swGetCookie(cname);
        var pageUrlVisited = __smartWidgetConditionFunctions__.pageUrlVisited;
        if (cookieUserOrdered) {
          if (cookieUserOrdered == 1) {
            return is === "is" ? true : false;
          }
          return is === "is" ? false : true;
        } else {
          if (window["RvstData"]) {
            var status = RvstData.Ordered;
            if (status == 1) {
              swSetCookie(cname, status, 10, hname);
              return is === "is" ? true : false;
            }
          } else {
            var orderPageArray = orderPage.split(",");
            for (var i = 0; i < orderPageArray.length; i++) {
              if (!orderPageArray[i].trim()) continue;
              if (
                currentUrl.includes(orderPageArray[i].toLowerCase()) ||
                pageUrlVisited("includes", orderPageArray[i].toLowerCase())
              ) {
                swSetCookie(cname, "1", 10, hname);
                return is === "is" ? true : false;
              }
            }
          }
        }
        return is === "is" ? false : true;
      };
  
      __smartWidgetConditionFunctions__.WebpushCheck = function WebpushCheck(
        status
      ) {
        var webpushStatus = swGetCookie("revotas_web_push");
        if (webpushStatus === status) return true;
        return false;
      };
  
      __smartWidgetConditionFunctions__.checkRecentlyViewed =
        function checkRecentlyViewed() {
          var cName = "rvts_product_history_array";
          var cookieRecentlyViewed = decodeURIComponent(swGetCookie(cName));
          if (cookieRecentlyViewed) {
            localStorage.setItem(cName, encodeURIComponent(cookieRecentlyViewed));
            swSetCookie(cName, "", -1, hname);
          } else {
            cookieRecentlyViewed = localStorage.getItem(cName)
              ? decodeURIComponent(localStorage.getItem(cName))
              : null;
          }
          if (cookieRecentlyViewed) {
            var productArray = JSON.parse(cookieRecentlyViewed);
            productArray = productArray.filter(function (product) {
              if (!product[0].date) return false;
              //else return true;
              else {
                var productDate = new Date(product[0].date);
                var now = new Date();
                var timeDiff = Math.round(
                  (now.getTime() - productDate.getTime()) / (1000 * 60 * 60)
                );
                return timeDiff < 24;
              }
            });
            productArray.sort((a, b) => b[0].date - a[0].date);
            localStorage.setItem(
              cName,
              encodeURIComponent(JSON.stringify(productArray))
            );
            if (productArray.length > 0) return true;
            else return false;
          } else return false;
        };
  
      __smartWidgetConditionFunctions__.locationCity = function locationCity(
        operator,
        cityName
      ) {
        return fetch("https://pro.ip-api.com/json?key=meqxcbbXZfQRbIa")
          .then((resp) => resp.json())
          .then((resp) => {
            cityName = cityName.toLowerCase();
            var city = resp.city.toLowerCase();
            if (!["is", "isnot", "includes", "notincludes"].includes(operator))
              operator = "is";
            if (operator === "is") {
              return cityName === city;
            } else if (operator === "isnot") {
              return cityName !== city;
            } else if (operator === "includes") {
              return city.includes(cityName);
            } else if (operator === "notincludes") {
              return !city.includes(cityName);
            }
          });
      };
  
      __smartWidgetConditionFunctions__.locationCountry =
        function locationCountry(operator, countryName) {
          return fetch("https://pro.ip-api.com/json?key=meqxcbbXZfQRbIa")
            .then((resp) => resp.json())
            .then((resp) => {
              countryName = countryName.toLowerCase();
              var country = resp.country.toLowerCase();
              if (!["is", "isnot", "includes", "notincludes"].includes(operator))
                operator = "is";
              if (operator === "is") {
                return countryName === country;
              } else if (operator === "isnot") {
                return countryName !== country;
              } else if (operator === "includes") {
                return country.includes(countryName);
              } else if (operator === "notincludes") {
                return !country.includes(countryName);
              }
            });
        };
  
      __smartWidgetConditionFunctions__.browser = function browser(browserName) {
        var browser = (function () {
          var test = function (regexp) {
            return regexp.test(window.navigator.userAgent);
          };
          switch (true) {
            case test(/edg/i):
              return "edge";
            case test(/trident/i):
              return "ie";
            case test(/firefox|fxios/i):
              return "firefox";
            case test(/opr\//i):
              return "opera";
            case test(/chrome|chromium|crios/i):
              return "chrome";
            case test(/safari/i):
              return "safari";
            default:
              return "other";
          }
        })();
        return browser === browserName;
      };
  
      __smartWidgetConditionFunctions__.operatingSystem =
        function operatingSystem(osName) {
          var userAgent = window.navigator.userAgent,
            platform = window.navigator.platform,
            macosPlatforms = ["Macintosh", "MacIntel", "MacPPC", "Mac68K"],
            windowsPlatforms = ["Win32", "Win64", "Windows", "WinCE"],
            iosPlatforms = ["iPhone", "iPad", "iPod"],
            os = null;
  
          if (macosPlatforms.indexOf(platform) !== -1) {
            os = "macos";
          } else if (iosPlatforms.indexOf(platform) !== -1) {
            os = "ios";
          } else if (windowsPlatforms.indexOf(platform) !== -1) {
            os = "windows";
          } else if (/Android/.test(userAgent)) {
            os = "android";
          } else if (!os && /Linux/.test(platform)) {
            os = "linux";
          } else {
            os = "other";
          }
  
          return os === osName;
        };
  
      __smartWidgetConditionFunctions__.executeScript = function executeScript(
        script,
        waitParam,
        pagesObj,
        popupId,
        widgetConfig
      ) {
        var evaluatedValue = false;
        try {
          if (waitParam === "waitpageload") {
            evaluatedValue = new Promise((resolve, reject) => {
              function ready() {
                var eValue = eval(
                  "(function(id,widgetConfig){" +
                    script +
                    '})("' +
                    popupId +
                    '",widgetConfig);'
                );
                resolve(eValue);
              }
              if (document.readyState === "complete") {
                ready();
              } else {
                window.addEventListener("load", ready);
              }
            });
          } else {
            evaluatedValue = eval(
              "(function(id,widgetConfig){" +
                script +
                '})("' +
                popupId +
                '",widgetConfig);'
            );
          }
        } catch (err) {
          console.warn(script);
          console.warn(
            "There was an error with the above smartwidget condition script"
          );
          console.warn("Smartwidget ID: " + popupId);
          console.warn(err);
        }
        return evaluatedValue;
      };
  
      __smartWidgetConditionFunctions__.weatherStatus = function weatherStatus(
        day,
        condition,
        status
      ) {
        var statusList = {
          Snowy: [
            "Blizzard",
            "Blowing snow",
            "Heavy snow",
            "Ice pellets",
            "Light sleet",
            "Light snow",
            "Light snow showers",
            "Moderate or heavy sleet",
            "Moderate or heavy snow with thunder",
            "Moderate snow",
            "Patchy heavy snow",
            "Patchy light snow",
            "Patchy light snow with thunder",
            "Patchy moderate snow",
            "Patchy sleet possible",
            "Patchy snow possible",
          ],
          Clear: ["Clear"],
          Cloudy: ["Cloudy", "Overcast", "Partly cloudy"],
          Foggy: ["Fog", "Freezing fog"],
          Rainy: [
            "Freezing drizzle",
            "Heavy freezing drizzle",
            "Heavy rain",
            "Heavy rain at times",
            "Light drizzle",
            "Light freezing rain",
            "Light rain",
            "Light rain shower",
            "Light showers of ice pellets",
            "Light sleet showers",
            "Moderate or heavy freezing rain",
            "Moderate or heavy rain shower",
            "Moderate or heavy rain with thunder",
            "Moderate or heavy showers of ice pellets",
            "Moderate or heavy sleet showers",
            "Moderate or heavy snow showers",
            "Moderate rain",
            "Moderate rain at times",
            "Patchy light rain",
            "Patchy light rain with thunder",
            "Patchy rain possible",
            "Torrential rain shower",
          ],
          Misty: ["Mist"],
          Drizzle: ["Patchy freezing drizzle possible", "Patchy light drizzle"],
          Sunny: ["Sunny"],
          Thunderstorm: ["Thundery outbreaks possible"],
        };
  
        return fetch("https://pro.ip-api.com/json?key=meqxcbbXZfQRbIa")
          .then((response) => response.json())
          .then((response) => {
            city = `${response.city}`;
            return city;
          })
          .then((city) => {
            return fetch(
              `https://api.weatherapi.com/v1/forecast.json?key=0a2eb54c67ce4d9e933103454212704&q=${city}&days=10`
            )
              .then((resp) => resp.json())
              .then((resp) => {
                var sonuc = false;
  
                resp.forecast.forecastday.forEach((res, ind) => {
                  if (ind < day) {
                    weather = `${resp.forecast.forecastday[ind].day.condition.text}`;
                    if (condition === "is") {
                      if (statusList[status].includes(weather)) sonuc = true;
                    } else if (condition === "isnot") {
                      if (!statusList[status].includes(weather)) sonuc = true;
                    }
                  }
                });
                return sonuc;
              });
          });
      };
  
      __smartWidgetConditionFunctions__.weatherDegree = function weatherDegree(
        operation,
        degree
      ) {
        var locationUrl = "https://pro.ip-api.com/json?key=meqxcbbXZfQRbIa";
        return fetch(locationUrl)
          .then((response) => response.json())
          .then((response) => {
            city = `${response.city}`;
            return city;
          })
          .then((city) => {
            return fetch(
              `https://api.weatherapi.com/v1/current.json?key=0a2eb54c67ce4d9e933103454212704&q=${city}&aqi=no`
            )
              .then((resp) => resp.json())
              .then((resp) => {
                var sonuc = false;
                var feelslike = `${resp.current.feelslike_c}`;
                if (operation === "=") {
                  if (feelslike == degree) sonuc = true;
                  else sonuc = false;
                }
                if (operation === ">") {
                  if (feelslike > degree) sonuc = true;
                  else sonuc = false;
                } else if (operation === ">=") {
                  if (feelslike >= degree) sonuc = true;
                  else sonuc = false;
                }
  
                if (operation === "<") {
                  if (feelslike < degree) sonuc = true;
                  else sonuc = false;
                } else if (operation === "<=") {
                  if (feelslike <= degree) sonuc = true;
                  else sonuc = false;
                }
                return sonuc;
              });
          });
      };
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.cookieValue,
        group: "User Rules",
        name: "Cookie Value",
        params: [
          {
            type: "text",
          },
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
              {
                name: "LIKE",
                value: "includes",
              },
              {
                name: "NOT LIKE",
                value: "notincludes",
              },
            ],
          },
          {
            type: "text",
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.deviceType,
        group: "User Rules",
        name: "Device type",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "Desktop",
                value: "desktop",
              },
              {
                name: "Mobile",
                value: "mobile",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.pageType,
        group: "Page Rules",
        name: "Page Type",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
            ],
          },
          {
            type: "list",
            elements: [
              {
                name: "Home",
                value: "home",
              },
              {
                name: "Category",
                value: "category",
              },
              {
                name: "Product",
                value: "product",
              },
              {
                name: "Cart",
                value: "cart",
              },
              {
                name: "Order",
                value: "order",
              },
              {
                name: "Search",
                value: "search",
              },
              {
                name: "404",
                value: "404",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.searchKeyword,
        group: "User Rules",
        name: "Searched Keyword",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
              {
                name: "LIKE",
                value: "includes",
              },
              {
                name: "NOT LIKE",
                value: "notincludes",
              },
            ],
          },
          {
            type: "text",
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.pageUrl,
        group: "Page Rules",
        name: "Page URL",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
              {
                name: "LIKE",
                value: "includes",
              },
              {
                name: "NOT LIKE",
                value: "notincludes",
              },
            ],
          },
          {
            type: "text",
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.pageUrlVisited,
        group: "Page Rules",
        name: "Page URL Visited",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
              {
                name: "LIKE",
                value: "includes",
              },
              {
                name: "NOT LIKE",
                value: "notincludes",
              },
            ],
          },
          {
            type: "text",
          },
        ],
      });
  
      var dayCount = 1;
      var dayList = Array.from(Array(30), () => {
        var obj = { name: dayCount, value: dayCount };
        dayCount++;
        return obj;
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.pageUrlVisitedDay,
        group: "Page Rules",
        name: "Page URL Visited Day",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
              {
                name: "LIKE",
                value: "includes",
              },
              {
                name: "NOT LIKE",
                value: "notincludes",
              },
            ],
          },
          {
            type: "list",
            elements: dayList,
          },
          {
            type: "text",
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.firstVisit,
        group: "User Rules",
        name: "New User",
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.returningUser,
        group: "Visit Rules",
        name: "Returning User",
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.gender,
        group: "User Rules",
        name: "Gender",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "Male",
                value: "male",
              },
              {
                name: "Female",
                value: "female",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.loggedIn,
        group: "User Rules",
        name: "Logged In",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.isMember,
        group: "User Rules",
        name: "Is member",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.isSubscribed,
        group: "User Rules",
        name: "Is Subscribed",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.addedToCart,
        group: "Cart Rules",
        name: "Added to cart",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
            ],
          },
        ],
      });
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.userOrdered,
        group: "User Rules",
        name: "User made order",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
            ],
          },
        ],
      });
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.timeSpent,
        group: "Visit Rules",
        name: "Time spent on site",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "Seconds",
                value: "seconds",
              },
              {
                name: "Minutes",
                value: "minutes",
              },
            ],
          },
          {
            type: "text",
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.weatherStatus,
        group: "Weather Rules",
        name: "Weather Status",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "Next 1 day",
                value: "1",
              },
              {
                name: "Next 2 days",
                value: "2",
              },
              {
                name: "Next 3 days",
                value: "3",
              },
              {
                name: "Next 4 days",
                value: "4",
              },
              {
                name: "Next 5 days",
                value: "5",
              },
            ],
          },
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
            ],
          },
          {
            type: "list",
            elements: [
              {
                name: "Snowy",
                value: "Snowy",
              },
              {
                name: "Clear",
                value: "Clear",
              },
              {
                name: "Cloudy",
                value: "Cloudy",
              },
              {
                name: "Foggy",
                value: "Foggy",
              },
              {
                name: "Rainy",
                value: "Rainy",
              },
              {
                name: "Misty",
                value: "Misty",
              },
              {
                name: "Drizzle",
                value: "Drizzle",
              },
              {
                name: "Sunny",
                value: "Sunny",
              },
              {
                name: "Thunderstorm",
                value: "Thunderstorm",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.weatherDegree,
        group: "Weather Rules",
        name: "Weather Degree",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "=",
                value: "=",
              },
              {
                name: ">",
                value: ">",
              },
              {
                name: "<",
                value: "<",
              },
              {
                name: ">=",
                value: ">=",
              },
              {
                name: "<=",
                value: "<=",
              },
            ],
          },
          {
            type: "text",
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.lastPopupShow,
        group: "Other Rules",
        name: "Last shown(days)",
        params: [{ type: "text" }],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.WebpushCheck,
        group: "Other Rules",
        name: "Webpush",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "Allowed",
                value: "true",
              },
              {
                name: "Blocked",
                value: "false",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.checkRecentlyViewed,
        group: "Page Rules",
        name: "Product Recently Viewed",
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.locationCity,
        group: "User Rules",
        name: "City",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
              {
                name: "LIKE",
                value: "includes",
              },
              {
                name: "NOT LIKE",
                value: "notincludes",
              },
            ],
          },
          { type: "text" },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.locationCountry,
        group: "User Rules",
        name: "Country",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "IS",
                value: "is",
              },
              {
                name: "IS NOT",
                value: "isnot",
              },
              {
                name: "LIKE",
                value: "includes",
              },
              {
                name: "NOT LIKE",
                value: "notincludes",
              },
            ],
          },
          { type: "text" },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.browser,
        name: "Browser",
        group: "User Rules",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "Chrome",
                value: "chrome",
              },
              {
                name: "Firefox",
                value: "firefox",
              },
              {
                name: "Edge",
                value: "edge",
              },
              {
                name: "Internet Explorer",
                value: "ie",
              },
              {
                name: "Opera",
                value: "opera",
              },
              {
                name: "Safari",
                value: "safari",
              },
              {
                name: "Other",
                value: "other",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.operatingSystem,
        group: "User Rules",
        name: "Operating System",
        params: [
          {
            type: "list",
            elements: [
              {
                name: "Windows",
                value: "windows",
              },
              {
                name: "Mac OS",
                value: "macos",
              },
              {
                name: "Linux",
                value: "linux",
              },
              {
                name: "Android",
                value: "android",
              },
              {
                name: "IOS",
                value: "ios",
              },
              {
                name: "Other",
                value: "other",
              },
            ],
          },
        ],
      });
  
      __smartWidgetFunctions__.push({
        f: __smartWidgetConditionFunctions__.executeScript,
        group: "Other Rules",
        name: "JS Code",
        params: [
          {
            type: "multiline",
          },
          {
            type: "list",
            elements: [
              {
                name: "Run Instantly",
                value: "instant",
              },
              {
                name: "Wait For Page Load",
                value: "waitpageload",
              },
            ],
          },
        ],
      });
  
      var swNavigateListenerSet = false;
  
      window.addEventListener("load", function () {
        var cust_id = rvtsPopupArray[0].rvts_customer_id;
  
        var newParam = "";
        var searchParams = window.location.search;
        if (searchParams?.includes("rvts-preview-id")) {
          newParam = searchParams;
          newParam = newParam?.split("?rvts-preview-id=")[1];
          let str = "";
          for (var i = 0; i < 30; i++) {
            str = str + newParam[i];
          }
          if (str !== "" && str !== undefined) {
            fetch(
              `https://f.revotas.com/frm/smartwidgets/get_smartwidget_config_param.jsp?cust_id=${cust_id}&popup_id=${str}`
            )
              .then((res) => res.json())
              .then((res) => {
                if (res[0].object.swPreview === true) {
                  executeGroup(
                    res[0].object.conditionConfig,
                    {
                      registerPage: res[0].registerPage,
                      cartPage: res[0].cartPage,
                      orderPage: res[0].orderPage,
                    },
                    res[0].popupId,
                    res[0].object
                  ).then(function (result) {
                    if (result === true) {
                      if (res[0].object.scriptCode)
                        res[0].object.scriptCode = decodeURIComponent(
                          res[0].object.scriptCode
                        );
                      var previewCustId = cust_id;
                      var previewPopupId = res[0].popupId;
                      var previewFormId = res[0].formId;
                      var previewPopupName = res[0].popupName;
                      var previewRcpLink = res[0].rcp_link;
  
                      var bannerDiv = document.createElement("div");
                      bannerDiv.style.cssText = `
                                  font-size: 24px;
                                  font-weight: bold;
                                  text-align: center;
                                  animation: yanipSonme 1s infinite;
                                  display: flex;
                                  padding:20px;
                                  height:40px;
                                  width:200px;
                                  color:white;
                                  background-color:#ff6600;
                                  justify-content:center;
                                  align-items:center;
                                  margin: 0px auto;
                                  position: relative;
                                  z-index: 99999;
                              `;
                      const styleTag = document.createElement("style");
                      styleTag.innerHTML = `
                               @keyframes yanipSonme {
                                  0% { opacity: 1; }
                                  50% { opacity: 0; }
                                  100% { opacity: 1; }
                              }`;
                      document.head.appendChild(styleTag);
                      bannerDiv.innerText = "TEST MODE";
                      document.body.prepend(bannerDiv);
                      rvtsPopup(
                        res[0].object,
                        false,
                        previewCustId,
                        previewPopupId,
                        previewPopupName,
                        previewFormId,
                        previewRcpLink,
                        true
                      );
                    }
                  });
                }
              })
              .catch((err) => console.log(err));
          }
        }
      });
  
      function swMessageListener(message) {
        var cust_id = rvtsPopupArray[0].rvts_customer_id;
        var origin = message.origin;
        var data = message.data;
        if (data.swCheckConnection && data.cust_id == cust_id) {
          var targetWindow = null;
          if (data.type === "iframe") targetWindow = window.parent;
          else if (data.type === "window") targetWindow = window.opener;
          targetWindow.postMessage(
            { swCheckConnection: true, href: window.location.href },
            origin
          );
          if (!swNavigateListenerSet) {
            window.addEventListener("beforeunload", function () {
              targetWindow.postMessage("swConnectionLost", origin);
              window.removeEventListener("message", swMessageListener);
            });
            swNavigateListenerSet = true;
          }
        } else if (data.swPreview) {
          executeGroup(
            data.conditionConfig,
            {
              registerPage: data.registerPage,
              cartPage: data.cartPage,
              orderPage: data.orderPage,
            },
            data.popupId,
            data
          ).then(function (result) {
            if (result) {
              if (data.html) data.html = decodeURIComponent(data.html);
              if (data.thankYouHtml)
                data.thankYouHtml = decodeURIComponent(data.thankYouHtml);
              if (data.scriptCode)
                data.scriptCode = decodeURIComponent(data.scriptCode);
              var previewCustId = data.custId;
              var previewPopupId = data.popupId;
              var previewFormId = data.formId;
              var previewPopupName = data.popupName;
              var previewRcpLink = data.rcp_link;
              rvtsPopup(
                data,
                false,
                previewCustId,
                previewPopupId,
                previewPopupName,
                previewFormId,
                previewRcpLink,
                true
              );
            }
          });
        } else if (data.swExecJSCode) {
          window.eval(decodeURIComponent(data.JSCode));
        }
      }
  
      if (
        typeof rvtsPopupArray !== "undefined" &&
        rvtsPopupArray[0].rvts_customer_id
      ) {
        window.addEventListener("message", swMessageListener);
      }
  
      if (
        !rvtsPopupAlreadyShown &&
        window["rvtsPopupArray"] &&
        rvtsPopupArray.length > 0
      ) {
        (async function () {
          var popupArray = [];
          var cust_id = rvtsPopupArray[0].rvts_customer_id;
          popupArray = await swSessionConfig;
          if (popupArray) popupArray = JSON.parse(popupArray);
          if (!popupArray) {
            popupArray = await fetch(
              "https://f.revotas.com/frm/smartwidgets/get_smartwidget_config.jsp?cust_id=" +
                cust_id
            ).then(function (resp) {
              return resp.json();
            });
            sessionStorage.setItem(
              "sw_session_config",
              JSON.stringify(popupArray)
            );
          }
          var breakFor = false;
          for (popup of popupArray) {
            let scheduleSatisfied = false;
            let obj = popup.object;
            if (obj.schedule) {
              if (obj.schedule === "scheduleDateRange") {
                let range = obj.scheduleRange.split("-");
                let now = new Date();
                let start = new Date(range[0]);
                let end = new Date(range[1]);
                if (now >= start && now <= end) {
                  //Run widget
                  scheduleSatisfied = true;
                }
              } else if (obj.schedule === "scheduleDaily") {
                let range = obj.scheduleDailyTimeRange.split("-");
                let startTime = range[0].trim().split(":");
                let endTime = range[1].trim().split(":");
                let now = new Date();
                let start = new Date();
                let end = new Date();
                start.setHours(...startTime);
                end.setHours(...endTime);
                if (now >= start && now <= end) {
                  //Run widget
                  scheduleSatisfied = true;
                }
              } else if (obj.schedule === "scheduleWeekly") {
                let weekDays = obj.scheduleWeeklyDay;
                let range = obj.scheduleWeeklyTimeRange.split("-");
                let startTime = range[0].trim().split(":");
                let endTime = range[1].trim().split(":");
                let now = new Date();
                let start = new Date();
                let end = new Date();
                start.setHours(...startTime);
                end.setHours(...endTime);
                if (
                  now >= start &&
                  now <= end &&
                  weekDays.includes(now.getDay().toString())
                ) {
                  //Run widget
                  scheduleSatisfied = true;
                }
              } else if (obj.schedule === "noSchedule") {
                scheduleSatisfied = true;
              }
            } else {
              scheduleSatisfied = true;
            }
  
            let nonBlocking = obj.nonBlocking;
            let formId = popup.formId;
            let popupId = popup.popupId;
            let popupName = popup.popupName;
            let rcpLink = popup.rcp_link;
            let registerPage = popup.registerPage;
            let cartPage = popup.cartPage;
            let orderPage = popup.orderPage;
            if (
              obj.enabled &&
              !obj.testWidget &&
              nonBlocking == 1 &&
              scheduleSatisfied
            ) {
              executeGroup(
                obj.conditionConfig,
                {
                  registerPage: registerPage,
                  cartPage: cartPage,
                  orderPage: orderPage,
                },
                popupId,
                popup
              ).then(function (result) {
                if (result) {
                  if (obj.html) obj.html = decodeURIComponent(obj.html);
                  if (obj.thankYouHtml)
                    obj.thankYouHtml = decodeURIComponent(obj.thankYouHtml);
                  if (obj.scriptCode)
                    obj.scriptCode = decodeURIComponent(obj.scriptCode);
                  rvtsPopup(
                    obj,
                    false,
                    cust_id,
                    popupId,
                    popupName,
                    formId,
                    rcpLink,
                    false
                  );
                }
              });
            } else if (
              obj.enabled &&
              !obj.testWidget &&
              !breakFor &&
              scheduleSatisfied
            ) {
              await executeGroup(
                obj.conditionConfig,
                {
                  registerPage: registerPage,
                  cartPage: cartPage,
                  orderPage: orderPage,
                },
                popupId,
                popup
              ).then(function (result) {
                if (result) {
                  if (obj.html) obj.html = decodeURIComponent(obj.html);
                  if (obj.thankYouHtml)
                    obj.thankYouHtml = decodeURIComponent(obj.thankYouHtml);
                  if (obj.scriptCode)
                    obj.scriptCode = decodeURIComponent(obj.scriptCode);
                  rvtsPopup(
                    obj,
                    false,
                    cust_id,
                    popupId,
                    popupName,
                    formId,
                    rcpLink,
                    false
                  );
                  if (
                    ![
                      "sticky",
                      "drawer",
                      "script",
                      "productAlert",
                      "socialProof",
                      "igStory",
                      "exitIntent",
                      "upsellProBar",
                      "imageTagging",
                      "notificationCenter",
                      "dealsDiscovery",
                      "countDown",
                      "pages",
                      "backInStock",
                      "abTest",
                      "whatsapp",
                      "dealOfDay",
                      "drawerDiscount",
                      "recentlyView",
                      "blockedWebpush",
                    ].includes(obj.type)
                  )
                    breakFor = true;
                }
              });
            }
          }
        })();
      }



          // Web push bildirimi engellendiğinde gösterilecek widget örneği
    let blockedWebpushConfig = {
      imageLink: "https://example.com/notification-image.png",
      imageWidth: 150,
      imageHeight: 150,
      
      // Açıklama
      desc: encodeURIComponent(encodeURIComponent("Web bildirimleri etkinleştirirseniz, indirimlerden haberdar olabilirsiniz.")),
      descColor: "#333333",
      descSize: 14,
      descAlign: "center",
      descFontFamily: "Arial",
      descFont: "normal",
      descFontStyle: "none",
      
      // Adımlar
      step1: encodeURIComponent("<b>Tarayıcınızın adres çubuğunu tıklayın</b>"),
      step2: encodeURIComponent("<b>Bildirimlere izin ver</b> seçeneğini tıklayın"),
      stepColor: "#555555",
      stepSize: 12,
      stepFontFamily: "Arial",
      stepFont: "normal",
      stepFontStyle: "none",
      
      // Buton
      buttonText: encodeURIComponent("Bildirimlere İzin Ver"),
      buttonColor: "#ffffff",
      buttonWidth: 200,
      buttonHeight: 40,
      buttonFontSize: 14,
      buttonFont: "bold",
      buttonAlign: "center",
      buttonFontStyle: "none",
      fontFamily: "Arial",
      
      // Buton arka plan
      isGradient: false,
      bg1: "#ff6600",  // Tek renk veya gradient başlangıç rengi
      bg2: "#ff9900",  // Gradient bitiş rengi
      
      // Widget tipi
      type: "blockedWebpush"
    };
    
    // Widget'ı çağırma
    rvtsPopup(
      blockedWebpushConfig,
      false,         // isPreview
      "customer_id", // custId
      "popup_id",    // popupId
      "Blocked Webpush Widget", // popupName
      "form_id",     // formId (opsiyonel)
      null,          // rcpLink (opsiyonel)
      false          // isLivePreview
    );



        // Web push'ın engellendiğini simüle etmek için
    localStorage.setItem("rvts_webpush_domain", "example.com");
    
    // Ve sonra widget'ı çağırın
    rvtsPopup(blockedWebpushConfig, false, "customer_id", "popup_id", "Blocked Webpush Widget", "form_id", null, false);
    }



  
    swLoadFunction()
  }
  