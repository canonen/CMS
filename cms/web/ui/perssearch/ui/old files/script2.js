//---------------------------------------------------------------------------------

var searchConfigurations = JSON.parse('{"inputSelector":"","submitSelector":"","title":"Sizin İçin Seçtiklerimiz","resultLimit":6,"recentlyViewedTitle":"Görüntülediğiniz Ürünler","lastSearchTitle":"Son Aramalarınız","categoriesTitle":"Kategoriler","categoriesLimit":5,"recommendedQueriesTitle":"Önerilenler","queryPattern":"","categories":[],"synonyms":[],"redirects":[],"recommendedQueries":[],"filter_id":0,"excludeRecentlyViewed":"0","excludeRecentlyPurchased":"0"}');

//----------------------------------------------------------

function insertAfter(newNode, existingNode) {
    existingNode.parentNode.insertBefore(newNode, existingNode.nextSibling);
}

function toggleButton(el) {
    var mainDiv = el.parentNode.parentNode.parentNode;
    var pinnedElements = Array.from(mainDiv.querySelectorAll('.categoryPinned.btn-primary'));
    var lastPinned = pinnedElements[pinnedElements.length - 1];
    if (lastPinned) lastPinned = lastPinned.parentNode.parentNode;
    if (el.classList.contains('btn-outline-primary')) {
        if (lastPinned)
            insertAfter(el.parentNode.parentNode, lastPinned);
        else
            mainDiv.insertBefore(el.parentNode.parentNode, mainDiv.children[0]);
        el.classList.remove('btn-outline-primary');
        el.classList.add('btn-primary');
    } else if (el.classList.contains('btn-primary')) {
        if (lastPinned)
            insertAfter(el.parentNode.parentNode, lastPinned);
        el.classList.remove('btn-primary');
        el.classList.add('btn-outline-primary');
    }
}

function deleteRedirect(element) {
    element.parentNode.parentNode.remove();
}

function deleteSynonym(element) {
    element.parentNode.parentNode.remove();
}

function deleteCategory(element) {
    element.parentNode.parentNode.remove();
}

function deleteQuery(element) {
    element.parentNode.parentNode.remove();
}

function getCategories() {
    var categoriesArray = [];
    var categoryNameList = Array.from(document.querySelectorAll('.categoryName'));
    var categoryLinkList = Array.from(document.querySelectorAll('.categoryLink'));
    var categoryPinnedList = Array.from(document.querySelectorAll('.categoryPinned'));
    categoryNameList.forEach((element, index) => {
        categoriesArray.push({
            name: encodeURIComponent(element.value),
            link: encodeURIComponent(categoryLinkList[index].value),
            pinned: encodeURIComponent(categoryPinnedList[index].classList.contains('btn-primary') ? 1 : 0)
        });
    });
    return categoriesArray;
}

function getRedirects() {
    var redirectsArray = [];
    var redirectNameList = Array.from(document.querySelectorAll('.redirectQuery'));
    var redirectLinkList = Array.from(document.querySelectorAll('.redirectLink'));
    redirectNameList.forEach((element, index) => {
        redirectsArray.push({
            query: encodeURIComponent(element.value),
            link: encodeURIComponent(redirectLinkList[index].value)
        });
    });
    return redirectsArray;
}

function getSynonyms() {
    var synonymsArray = [];
    var originalKeywordList = Array.from(document.querySelectorAll('.originalKeyword'));
    var synonymKeywordList = Array.from(document.querySelectorAll('.synonymKeyword'));
    originalKeywordList.forEach((element, index) => {
        synonymsArray.push({
            original: encodeURIComponent(element.value),
            synonym: encodeURIComponent(synonymKeywordList[index].value)
        });
    });
    return synonymsArray;
}

function getQueries() {
    return Array.from(document.querySelectorAll('.queryName')).map(element => encodeURIComponent(element.value));
}

function addSynonym(original, synonym) {
    if (!original) original = '';
    if (!synonym) synonym = '';
    var synonymsDiv = document.querySelector('.synonyms');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-6');
    newDiv.innerHTML = '<div class="form-group col-3"> <input type="text" class="form-control originalKeyword" placeholder="Original Keyword" value="' + original + '"> </div> <div class="form-group col-3"> <input type="text" class="form-control synonymKeyword" placeholder="Synonym Keyword" value="' + synonym + '"> </div> <div class="form-group col-1"> <button onclick="deleteSynonym(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    synonymsDiv.appendChild(newDiv);
}

function addCategory() {
    var categoriesDiv = document.querySelector('.categories');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-8');
    newDiv.innerHTML = '<div class="form-group col-1"><button onclick="toggleButton(this)" type="button" class="categoryPinned btn btn-block btn-outline-primary btn-sm" style="height: 100%;">Pin</button></div><div class="form-group col-2"> <input type="text" class="form-control categoryName" placeholder="Category Name"> </div> <div class="form-group col-8"> <input type="text" class="form-control categoryLink" placeholder="Category Link"> </div> <div class="form-group col-1"> <button onclick="deleteCategory(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button></div>';
    categoriesDiv.appendChild(newDiv);
}

function addRedirect() {
    var redirectsDiv = document.querySelector('.redirects');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-6');
    newDiv.innerHTML = '<div class="form-group col-3"> <input type="text" class="form-control redirectQuery" placeholder="Query"> </div> <div class="form-group col-8"> <input type="text" class="form-control redirectLink" placeholder="Redirect Link"> </div> <div class="form-group col-1"> <button onclick="deleteRedirect(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    redirectsDiv.appendChild(newDiv);
}

function addQuery() {
    var queriesDiv = document.querySelector('.queries');
    var newDiv = document.createElement('div');
    newDiv.classList.add('row');
    newDiv.classList.add('col-md-6');
    newDiv.innerHTML = '<div class="form-group col-3"> <input type="text" class="form-control queryName" placeholder="Query"> </div> <div class="form-group col-1"> <button onclick="deleteQuery(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
    queriesDiv.appendChild(newDiv);
}

function renderCategories(categories) {
    var categoriesDiv = document.querySelector('.categories');
    categoriesDiv.innerHTML = '';
    var categoryElements = categories.forEach((category, index) => {
        var newDiv = document.createElement('div');
        newDiv.classList.add('row');
        newDiv.classList.add('col-md-8');
        newDiv.innerHTML = '<div class="form-group col-1"><button onclick="toggleButton(this)" type="button" class="categoryPinned btn btn-block btn' + (decodeURIComponent(category.pinned) == 1 ? '' : '-outline') + '-primary btn-sm" style="height: 100%;">Pin</button></div><div class="form-group col-2"> <input type="text" class="form-control categoryName" value="' + decodeURIComponent(category.name) + '" placeholder="Category Name"> </div> <div class="form-group col-8"> <input type="text" class="form-control categoryLink" value="' + decodeURIComponent(category.link) + '" placeholder="Category Link"> </div> <div class="form-group col-1"> <button onclick="deleteCategory(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
        categoriesDiv.appendChild(newDiv);
    });
}

function renderRedirects(redirects) {
    var redirectsDiv = document.querySelector('.redirects');
    redirectsDiv.innerHTML = '';
    var redirectElements = redirects.forEach((redirect, index) => {
        var newDiv = document.createElement('div');
        newDiv.classList.add('row');
        newDiv.classList.add('col-md-6');
        newDiv.innerHTML = '<div class="form-group col-3"> <input type="text" class="form-control redirectQuery" value="' + decodeURIComponent(redirect.query) + '" placeholder="Query"> </div> <div class="form-group col-8"> <input type="text" class="form-control redirectLink" value="' + decodeURIComponent(redirect.link) + '" placeholder="Redirect Link"> </div> <div class="form-group col-1"> <button onclick="deleteRedirect(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
        redirectsDiv.appendChild(newDiv);
    });
}

function renderSynonyms(synonyms) {
    var synonymsDiv = document.querySelector('.synonyms');
    synonymsDiv.innerHTML = '';
    var synonymElements = synonyms.forEach((synonym, index) => {
        var newDiv = document.createElement('div');
        newDiv.classList.add('row');
        newDiv.classList.add('col-md-6');
        newDiv.innerHTML = '<div class="form-group col-3"> <input type="text" class="form-control originalKeyword" value="' + decodeURIComponent(synonym.original) + '" placeholder="Original Keyword"> </div> <div class="form-group col-3"> <input type="text" class="form-control synonymKeyword" value="' + decodeURIComponent(synonym.synonym) + '" placeholder="Synonym Keyword"> </div> <div class="form-group col-1"> <button onclick="deleteCategory(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
        synonymsDiv.appendChild(newDiv);
    });
}

function renderQueries(queries) {
    var queriesDiv = document.querySelector('.queries');
    queriesDiv.innerHTML = '';
    var queryElements = queries.forEach((query, index) => {
        var newDiv = document.createElement('div');
        newDiv.classList.add('row');
        newDiv.classList.add('col-md-6');
        newDiv.innerHTML = '<div class="form-group col-3"> <input type="text" class="form-control queryName" value="' + decodeURIComponent(query) + '" placeholder="Query"> </div> <div class="form-group col-1"> <button onclick="deleteQuery(this)" style="display: flex; justify-content: center;" type="button" class="btn btn-block btn-danger">X</button> </div>';
        queriesDiv.appendChild(newDiv);
    });
}



document.getElementById("deleteImage").addEventListener("click", () => {
    document.getElementById("perSearch_image_link").value = "";
    document.getElementById("search-image").src = document.getElementById("perSearch_image_link").value;
})





function renderConfigs(configs, status) {

    if (configs.image !== "") {
        document.getElementById("perSearch_image_link").value = configs.image;
        document.getElementById("search-image").src = configs.image;
        document.getElementById("search-image").href = configs.imageLink;
    }

    if (document.getElementById("perSearch_image_link").value === "undefined") {
        console.log("buraya girdi")
        document.getElementById("search-image").src = "";
        document.getElementById("perSearch_image_link").value = ""
    }

    if (!configs) return;
    for (var key in configs) {
        if (key === 'categories')
            renderCategories(configs[key]);
        else if (key === 'recommendedQueries')
            renderQueries(configs[key])
        else if (key === 'synonyms')
            renderSynonyms(configs[key])
        else if (key === 'redirects')
            renderRedirects(configs[key])
        else if (['showLastSearch', 'appendUTM', 'excludeRecentlyViewed', 'excludeRecentlyPurchased'].includes(key))
            document.getElementById(key).checked = parseInt(decodeURIComponent(configs[key]));
        else if (document.getElementById(key))
            document.getElementById(key).value = decodeURIComponent(configs[key]);
    }
    document.getElementById('searchStatus').checked = parseInt(status);
    if (typeof alreadyLoaded === 'undefined') {
        fetch('template.css')
            .then(resp => resp.text())
            .then(resp => {
                document.getElementById('css').value = resp;
            });
    }
    if (configs['filterConfigs']) {
        setFilterConfigs(configs['filterConfigs']);
    }
}


if (typeof alreadyLoaded === 'undefined') {
    renderConfigs(searchConfigurations, 1);
}
var perSearchImageUploadInput = document.getElementById('perSearchImageUpload');
var newUrl = ""
perSearchImageUploadInput.addEventListener('change', function (event) {
    var currentImage = event.target.files[0];
    if (currentImage.name.toLowerCase().endsWith('.gif')
        || currentImage.name.toLowerCase().endsWith('.jpg')
        || currentImage.name.toLowerCase().endsWith('.png')
        || currentImage.name.toLowerCase().endsWith('.jpeg')) {
        mediaThumbnail = null;
        document.getElementById('perSearchSelectImageUpload').style.display = '';
    }

    var formData = new FormData();

    formData.append(currentImage.name, currentImage);

    fetch('https://l.revotas.com:70/uploadimg/' + 790, {
        method: 'POST',
        body: formData
    }).then(response => response.json())
        .then(response => (imageUrl = response.data.img_url)).then(() => {
            perSearchImageUploadInput.style.display = '';
            perSearchImageUploadInput.removeAttribute('disabled');
            document.getElementById('perSearchSelectImageUpload').style.display = 'none';
            var imageLinkInput = document.getElementById('perSearch_image_link');
            imageLinkInput.value = imageUrl;
            newUrl = imageUrl
            document.getElementById("search-image").src = imageUrl
        }).catch(error => {
            console.log(error);
        });

});




function getConfigs() {
    var configObj = {};
    configObj.filter_id = productFilterConditionConfig.filterId;
    var inputList = [
        'inputSelector',
        'submitSelector',
        'title',
        'resultLimit',
        'sortCriteria',
        'fallbackScenario',
        'recentlyViewedTitle',
        'showLastSearch',
        'appendUTM',
        'lastSearchTitle',
        'categoriesTitle',
        'categoriesLimit',
        'recommendedQueriesTitle',
        'queryPattern',
        'categories',
        'synonyms',
        'redirects',
        'recommendedQueries',
        'css',
        'excludeRecentlyViewed',
        'excludeRecentlyPurchased',
        'image',
        'imageLink',
        'placeholderItems'
    ];
    inputList.forEach(key => {
        if (key === 'categories') {
            configObj.categories = getCategories();
        } else if (key === 'recommendedQueries') {
            configObj.recommendedQueries = getQueries();
        } else if (key === 'synonyms') {
            configObj.synonyms = getSynonyms();
        } else if (key === 'redirects') {
            configObj.redirects = getRedirects();
        } else if (key === 'placeholderItems') {
            let tempWords = document.getElementById("placeholderItems")
            configObj.placeholderItems = tempWords.value.split(",");
        } else if (key === 'image') {
            configObj.image = document.getElementById('perSearch_image_link').value;
        } else if (key === 'imageLink') {
            configObj.imageLink = document.getElementById('imageLink').value;
        } else if (['showLastSearch', 'appendUTM', 'excludeRecentlyViewed', 'excludeRecentlyPurchased'].includes(key)) {
            configObj[key] = encodeURIComponent(document.getElementById(key).checked ? 1 : 0);
        } else {
            configObj[key] = encodeURIComponent(document.getElementById(key).value);
        }
    });
    configObj['filterConfigs'] = getFilterConfigs();
    configObj['currencyConfigs'] = currencyConfigs;
    return configObj;
}





function saveConfigurations(custId, btn) {
    if (!custId)
        return;
    btn.setAttribute('disabled', true);
    var configsToSave = JSON.stringify(getConfigs());
    var configs = getConfigs();
    var filter_id = configs.filter_id;
    var exclude_recently_purchased = configs.excludeRecentlyPurchased;
    var exclude_recently_viewed = configs.excludeRecentlyViewed;
    var enabled = document.getElementById('searchStatus').checked ? 1 : 0;
    fetch('https://cms.revotas.com/cms/ui/perssearch/save_perssearch_config.jsp?cust_id=' + custId + '&enabled=' + enabled + '&rcp_link=' + rcpLink + (filter_id ? ('&filter_id=' + filter_id) : '') + (exclude_recently_purchased ? ('&exclude_recently_purchased=' + exclude_recently_purchased) : '') + (exclude_recently_viewed ? ('&exclude_recently_viewed=' + exclude_recently_viewed) : ''), {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: configsToSave
    }).then(() => {
        fetch('https://f.revotas.com/frm/perssearch/save_perssearch_config.jsp?cust_id=' + custId + '&enabled=' + enabled + '&rcp_link=' + rcpLink + (filter_id ? ('&filter_id=' + filter_id) : '') + (exclude_recently_purchased ? ('&exclude_recently_purchased=' + exclude_recently_purchased) : '') + (exclude_recently_viewed ? ('&exclude_recently_viewed=' + exclude_recently_viewed) : ''), {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: configsToSave
        }).then(() => {
            fetch('https://' + rcpLink + '/rrcp/imc/perssearch/save_perssearch_config.jsp?cust_id=' + custId + '&enabled=' + enabled + '&rcp_link=' + rcpLink + (filter_id ? ('&filter_id=' + filter_id) : '') + (exclude_recently_purchased ? ('&exclude_recently_purchased=' + exclude_recently_purchased) : '') + (exclude_recently_viewed ? ('&exclude_recently_viewed=' + exclude_recently_viewed) : ''), {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: configsToSave
            }).then(() => {
                fetch('https://' + rcpLink + '/rrcp/imc/perssearch/index.jsp?cust_id=' + custId).then(() => {
                    btn.removeAttribute('disabled');
                    alert('Configurations saved successfully');
                }).catch(() => {
                    btn.removeAttribute('disabled');
                    alert('An error has been occurred');
                });
            }).catch(() => {
                btn.removeAttribute('disabled');
                alert('An error has been occurred');
            });
        }).catch(() => {
            btn.removeAttribute('disabled');
            alert('An error has been occurred');
        });
    });



}

function selectAll(element) {
    element.setSelectionRange(0, -1);
}

function filterBox(option) {
    function generateId() {
        return [...Array(10)].map(i => (~~(Math.random() * 36)).toString(36)).join('');
    }
    var callbackFn = null;
    var enabled = false;
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
    head.innerHTML = '<input id="' + headId + '" type="checkbox"><label for="' + headId + '"></label><span>' + decodeURIComponent(title) + '</span>';
    var filterToggle = head.querySelector('input');
    var filterTitle = head.querySelector('span');
    filterToggle.addEventListener('change', e => {
        enabled = e.target.checked;
        if (typeof callbackFn === 'function') callbackFn.call(element, getValues());
    })
    filterTitle.addEventListener('click', () => {
        if (body.classList.contains('rvts_personalized_search_main-filter-expand-' + type))
            body.classList.remove('rvts_personalized_search_main-filter-expand-' + type);
        else
            body.classList.add('rvts_personalized_search_main-filter-expand-' + type);
    });
    element.appendChild(head);
    var body = document.createElement('div');
    body.style.height = 0;
    if (type === 'select') {
        var selectAllCheck = document.createElement('input');
        selectAllCheck.type = 'checkbox';
        selectAllCheck.checked = false;
        selectAllCheck.addEventListener('change', e => {
            var selectStatus = e.target.checked;
            selectList.filter(select => select.style.display !== 'none').forEach(select => select.querySelector('input').checked = selectStatus);
            if (selectStatus && !enabled) {
                enabled = !enabled;
                filterToggle.checked = enabled;
            }
            if (typeof callbackFn === 'function') callbackFn.call(element, getValues());
        })
        head.appendChild(selectAllCheck);
        body.classList.add('rvts_personalized_search_main-filter-select');
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
            var label = el.string;
            var meta = el.meta;
            if (!meta) meta = name;
            var newId = generateId();
            var newDiv = document.createElement('div');
            newDiv.classList.add('rvts_personalized_search_main-filter-item');
            newDiv.innerHTML = '<input meta="' + meta + '" id="' + newId + '" type="checkbox"><label for="' + newId + '">' + label + '</label>';
            newDiv.querySelector('input').addEventListener('change', e => {
                if (e.target.checked && !enabled) {
                    enabled = !enabled;
                    filterToggle.checked = enabled;
                }
                if (typeof callbackFn === 'function') callbackFn.call(element, getValues());
            });
            innerBody.appendChild(newDiv);
            selectListObject[encodeURIComponent(label) + '_' + encodeURIComponent(meta)] = newDiv.querySelector('input');
            return newDiv;
        });
        element.appendChild(body);
        if (selectList.length < 10) inputDiv.style.display = 'none';
    } else if (type === 'range') {
        body.classList.add('rvts_personalized_search_main-filter-range');
        lowerRange = document.createElement('input');
        lowerRange.type = 'number';
        var dash = document.createElement('span');
        dash.innerText = '-';
        upperRange = document.createElement('input');
        upperRange.type = 'number';
        lowerRange.addEventListener('change', () => { enabled = true; filterToggle.checked = enabled; if (typeof callbackFn === 'function') callbackFn.call(element, getValues()); });
        upperRange.addEventListener('change', () => { enabled = true; filterToggle.checked = enabled; if (typeof callbackFn === 'function') callbackFn.call(element, getValues()); });
        body.appendChild(lowerRange);
        body.appendChild(dash);
        body.appendChild(upperRange);
        if (option.range) {
            lowerRange.value = option.range[0];
            upperRange.value = option.range[1];
        }
        element.appendChild(body);
    }

    var getValues = function () {
        if (selectList) {
            return enabled && {
                name: name,
                type: type,
                list: selectList
                    .filter(selectDiv => selectDiv.querySelector('input').checked)
                    .map(selectDiv => {
                        return {
                            string: selectDiv.querySelector('label').innerText,
                            meta: selectDiv.querySelector('input').getAttribute('meta')
                        };
                    })
            };
        } else if (lowerRange && upperRange) {
            return enabled && {
                name: name,
                type: type,
                range: [lowerRange.value, upperRange.value]
            };
        }
    }

    return {
        getValues: getValues,
        toggle: function () {
            enabled = !enabled;
            filterToggle.checked = enabled;
        },
        selectAll: function () {
            if (selectList)
                selectList.forEach(selectDiv => selectDiv.querySelector('input').checked = true);
        },
        deselectAll: function () {
            if (selectList)
                selectList.forEach(selectDiv => selectDiv.querySelector('input').checked = false);
        },
        getConfig: function () {
            if (selectList) {
                var list = selectList
                    .filter(selectDiv => selectDiv.querySelector('input').checked)
                    .map(selectDiv => {
                        return {
                            string: encodeURIComponent(selectDiv.querySelector('label').innerText),
                            meta: encodeURIComponent(selectDiv.querySelector('input').getAttribute('meta'))
                        };
                    })
                return {
                    enabled: enabled,
                    name: name,
                    type: type,
                    title: encodeURIComponent(filterTitle.innerText),
                    list: list
                }
            } else if (lowerRange && upperRange) {
                return {
                    enabled: enabled,
                    name: name,
                    type: type,
                    title: encodeURIComponent(filterTitle.innerText),
                    range: [lowerRange.value, upperRange.value]
                }
            }
        },
        setConfig: function (config) {
            if (config.list) {
                this.deselectAll();
                title = decodeURIComponent(config.title);
                filterTitle.innerText = title;
                enabled = config.enabled;
                filterToggle.checked = config.enabled;
                config.list.forEach(element => {
                    if (selectListObject[element.string + '_' + element.meta])
                        selectListObject[element.string + '_' + element.meta].checked = true;
                });
            } else if (config.range) {
                title = decodeURIComponent(config.title);
                filterTitle.innerText = title;
                enabled = config.enabled;
                filterToggle.checked = config.enabled;
                lowerRange.value = config.range[0];
                upperRange.value = config.range[1];
            }
        },
        subscribe: function (fn) {
            callbackFn = fn;
        },
        element: element
    };
}

function getFilterConfigs() {
    var filterConfigObj = {};
    for (var key in filterObj) {
        var filterConfig = filterObj[key].getConfig();
        filterConfigObj[filterConfig.name] = filterConfig;
    }
    return filterConfigObj;
}

function setFilterConfigs(filterConfigObj) {
    for (var key in filterConfigObj) {
        if (filterObj[key]) {
            var filterConfig = filterConfigObj[key];
            filterObj[key].setConfig(filterConfig);
        }
    }
}

function handleChange(input) {
    if (input.min && input.value < input.min) input.value = input.min;
    if (input.max && input.value > input.max) input.value = input.max;
}

//product filtering section

var __productFilterFunctions__ = null
var productFilterConditionConfig = null;
var conditionSelect = null;
var productFilterConditionConfigs = null;
var productFilterResolver = null;
var productFilterFetched = new Promise((resolve, reject) => {
    productFilterResolver = resolve;
});

productFilterFetched.then((result) => {
    if (!result) return;
    document.getElementById('save-conditions').removeAttribute('disabled');
    document.getElementById('delete-condition').removeAttribute('disabled');
});

(async function () {

    try {

        __productFilterFunctions__ = await fetch('https://' + rcpLink + '/rrcp/imc/recommendation/get_product_filter_attributes.jsp?cust_id=' + custId)
            .then(resp => resp.json());

        productFilterConditionConfigs = await fetch('https://' + rcpLink + '/rrcp/imc/recommendation/get_recommendation_filter.jsp?cust_id=' + custId)
            .then(resp => resp.json());

        __productFilterFunctions__.sort((a, b) => {
            if (a.name < b.name) { return -1; }
            if (a.name > b.name) { return 1; }
            return 0;
        });

        var filterSelect = document.getElementById('productFilters');
        filterSelect.innerHTML = '<option value="-1">[NO FILTER]</option>';
        productFilterConditionConfigs.forEach(function (filter) {
            var option = document.createElement('option');
            option.innerText = filter.filterName;
            option.value = filter.filterId;
            filterSelect.appendChild(option);
        });

        filterSelect.addEventListener('change', function (ev) {
            var index = productFilterConditionConfigs.findIndex(e => e.filterId == ev.target.value);
            if (index != -1) {
                document.querySelector('.condition-configs').style.display = '';
                document.getElementById('save-conditions').style.display = '';
                document.getElementById('delete-condition').style.display = '';
                productFilterConditionConfig = productFilterConditionConfigs[index];
                document.getElementById('filterName').value = ev.target.children[ev.target.selectedIndex].innerText;
                fillGroupObject(productFilterConditionConfig);
                reRender();
            } else {
                productFilterConditionConfig = { filterId: 0 };
                document.querySelector('.condition-configs').style.display = 'none';
                document.getElementById('save-conditions').style.display = 'none';
                document.getElementById('delete-condition').style.display = 'none';
            }
        });

        conditionSelect = document.createElement('select');
        __productFilterFunctions__.forEach(function (element) {
            var option = document.createElement('option');
            option.value = element.name;
            option.innerText = element.name;
            option.params = element.params;
            conditionSelect.appendChild(option);
        });
        conditionSelect.classList.add('form-control');
        conditionSelect.style.width = '200px';

        var index = productFilterConditionConfigs.findIndex(e => e.filterId == configObj.filter_id);
        if (index == -1) {
            productFilterConditionConfig = { filterId: 0 };
        } else {
            productFilterConditionConfig = productFilterConditionConfigs[index];
        }
        if (configObj.filter_id != 'null' && configObj.filter_id > 0) filterSelect.value = configObj.filter_id;

        if (productFilterConditionConfig && productFilterConditionConfig.filterId) {
            fillGroupObject(productFilterConditionConfig);
            reRender();
        }

        if (configObj.filter_id == 0 || configObj.filter_id == 'null') {
            document.querySelector('.condition-configs').style.display = 'none';
            document.getElementById('save-conditions').style.display = 'none';
            document.getElementById('delete-condition').style.display = 'none';
        }

        document.getElementById('save-conditions').addEventListener('click', function () {
            if (productFilterConditionConfig && productFilterConditionConfig.filterId) {
                var btn = this;
                btn.setAttribute('disabled', 'true');
                fetch('https://' + rcpLink + '/rrcp/imc/recommendation/save_recommendation_filter.jsp?cust_id=' + custId, {
                    method: 'POST',
                    body: JSON.stringify(clearGroupObject(productFilterConditionConfig))
                }).then(resp => resp.text()).then(resp => {
                    productFilterConditionConfig.filterId = resp.trim();
                    filterSelect.children[filterSelect.selectedIndex].value = productFilterConditionConfig.filterId;
                    fetch('https://' + rcpLink + '/rrcp/imc/recommendation/process_recommendation_filter.jsp?cust_id=' + custId + '&filter_id=' + productFilterConditionConfig.filterId)
                        .then(resp => resp.json())
                        .then(resp => {
                            if (resp.status === 'error') {
                                alert(resp.message);
                            } else {
                                btn.removeAttribute('disabled');
                                alert("Product filter saved & processed successfully");
                            }
                        }).catch(function () {
                            btn.removeAttribute('disabled');
                            alert('An error has been occurred');
                        });
                });
            } else {
                alert('Please select a filter to save');
            }
        });

        document.getElementById('delete-condition').addEventListener('click', function () {
            var answer = confirm('Are you sure you want to delete selected filter?');
            if (answer) {
                var btn = this;
                btn.setAttribute('disabled', 'true');
                fetch('http://' + rcpLink + '/rrcp/imc/recommendation/delete_recommendation_filter.jsp?cust_id=' + custId + '&filter_id=' + productFilterConditionConfig.filterId).then(resp => resp.json()).then(resp => {
                    alert(resp.message);
                    btn.removeAttribute('disabled');
                    filterSelect.children[filterSelect.selectedIndex].remove();
                    filterSelect.children[0].selected = true;
                    productFilterConditionConfig = { filterId: 0 };
                    document.querySelector('.condition-configs').style.display = 'none';
                    document.getElementById('save-conditions').style.display = 'none';
                    document.getElementById('delete-condition').style.display = 'none';
                });
            }
        });

        document.getElementById('new-condition').addEventListener('click', function () {
            if (document.getElementById('filterName').value.trim() == '') {
                alert('Please enter a valid name for filter');
                return;
            }
            var minFilterId = Array.from(document.querySelector("#productFilters").children).map(e => parseInt(e.value)).sort((a, b) => (a - b))[0] - 1;
            var newFilterObj = { elements: [], filterId: minFilterId, operator: 'AND', flag: 0, type: 'group', filterName: document.getElementById('filterName').value };
            productFilterConditionConfigs.push(newFilterObj);
            var option = document.createElement('option');
            option.innerText = newFilterObj.filterName;
            option.value = newFilterObj.filterId;
            filterSelect.appendChild(option);
            document.querySelector("#productFilters").selectedIndex = document.querySelector("#productFilters").childElementCount - 1;
            productFilterConditionConfig = newFilterObj;
            fillGroupObject(productFilterConditionConfig);
            reRender();
            document.querySelector('.condition-configs').style.display = '';
            document.getElementById('save-conditions').style.display = '';
        });

        productFilterResolver(true);

    } catch (err) {
        productFilterResolver(false);
        console.warn(err);
    }

})();

var productFilterConditionConfig = {};

var lastConditionElement = null;
function reRender() {
    if (productFilterConditionConfig.htmlElement) productFilterConditionConfig.htmlElement.remove();
    if (lastConditionElement) lastConditionElement.remove();
    lastConditionElement = renderGroup(productFilterConditionConfig);
    document.querySelector('.condition-panel').appendChild(lastConditionElement);
}

function generateId() {
    return 'i' + [...Array(20)].map(i => (~~(Math.random() * 36)).toString(36)).join('');
}

function resetCheckInputs(id) {
    Array.from(document.querySelectorAll('input.condition-box:not(.' + id + '),input.group-box:not(.' + id + ')')).forEach(function (element) {
        element.checked = false;
    });
}

var logicSelect = document.createElement('select');
logicSelect.innerHTML = '<option value="AND">AND</option>' +
    '<option value="OR">OR</option>'
logicSelect.classList.add('form-control');
logicSelect.style.width = 'auto';

/*var groupPositiveSelect = document.createElement('select');
groupPositiveSelect.innerHTML = '<option value="IS">IS</option>' +
    '<option value="IS NOT">IS NOT</option>'
groupPositiveSelect.classList.add('form-control');
groupPositiveSelect.style.width = 'auto';*/


var groupExcludeSwitch = document.createElement('div');
groupExcludeSwitch.classList.add("custom-control");
groupExcludeSwitch.classList.add("custom-switch");
groupExcludeSwitch.appendChild((() => {
    var input = document.createElement('input');
    input.type = 'checkbox';
    input.classList.add("custom-control-input");
    return input;
})());
groupExcludeSwitch.appendChild((() => {
    var label = document.createElement('label');
    label.classList.add("custom-control-label");
    label.textContent = 'Exclude';
    label.style.fontWeight = 'unset';
    return label;
})());



function condition(f, params) {
    this.type = 'condition';
    this.f = f;
    this.flag = 0;
    this.params = [];
    var thisRef = this;
    if (params) {
        params.forEach(function (param, index) {
            if (param.type === 'list') {
                thisRef.params[index] = param.elements[0].value;
            }
        });
    }
}

var addElement = function (e) {
    e.parent = this;
    this.elements.push(e);
}

var removeElement = function (e, keep) {
    this.elements = this.elements.filter(function (obj) {
        return obj !== e;
    });
    if (this.elements.length === 0) {
        if (this.parent && !keep)
            this.parent.removeElement(this);
    }
}

function group(operator, ...e) {
    this.type = 'group';
    this.elements = [];
    for (var i = 0; i < e.length; i++) {
        e[i].parent = this;
        this.elements.push(e[i]);
    }
    this.operator = operator;
    this.flag = 0;
    this.addElement = addElement;
    this.removeElement = removeElement;
}

function clearGroupObject(groupElement) {
    var newGroup = Object.assign({}, groupElement);
    delete newGroup.parent;
    delete newGroup.htmlElement;
    delete newGroup.addElement;
    delete newGroup.removeElement;
    if (groupElement.elements) newGroup.elements = groupElement.elements.map(function (element) {
        var newElement = Object.assign({}, element);
        delete newElement.parent;
        delete newElement.htmlElement;
        delete newElement.addElement;
        delete newElement.removeElement;
        return clearGroupObject(newElement);
    });
    return newGroup;
};

function fillGroupObject(group) {
    if (group.type === 'group') {
        group.addElement = addElement;
        group.removeElement = removeElement;
    }
    if (!group.elements)
        return group;
    else {
        group.elements.forEach(function (element) {
            element.parent = group;
            if (element.type === 'group') {
                element.addElement = addElement;
                element.removeElement = removeElement;
            }
            fillGroupObject(element);
        });
    }
}

function renderParams(selectElement, group, preserveValues) {
    var newSelectFunc = null;
    var params = selectElement.children[selectElement.selectedIndex].params;
    while (selectElement.nextSibling)
        selectElement.nextSibling.remove();
    if (params) {
        var x = __productFilterFunctions__[__productFilterFunctions__.findIndex(e => e.name == group.f)].params[1].elements[7];
        if (x && x.name == 'BETWEEN' && x.value == 80 && group.params[1] == 80) x = 1;
        else x = 0;
        if (group.params.length > params.length + x)
            group.params.length -= group.params.length - params.length - x;
        params.forEach(function (param, index) {
            if (param.type === 'list') {
                var newSelect = document.createElement('select');
                newSelect.classList.add('form-control');
                newSelect.style.width = 'auto';
                param.elements.forEach(function (element) {
                    var newOption = document.createElement('option');
                    newOption.value = element.value;
                    newOption.innerText = element.name;
                    newSelect.appendChild(newOption);
                });
                var lastCreatedInput = null;
                newSelectFunc = function () {
                    var selectedOpt = newSelect.children[newSelect.selectedIndex];
                    if (selectedOpt.innerText == 'BETWEEN' && selectedOpt.value == 80) {
                        lastCreatedInput = lastCreatedInput ? lastCreatedInput : document.createElement('input');
                        lastCreatedInput.classList.add('form-control');
                        lastCreatedInput.style.width = 'auto';
                        lastCreatedInput.addEventListener('change', function (e) {
                            group.params[params.length] = e.target.value;
                        });
                        var elementToAdd = selectElement;
                        while (elementToAdd.nextSibling)
                            elementToAdd = elementToAdd.nextSibling;
                        if (elementToAdd.type == 'submit') elementToAdd = elementToAdd.previousSibling;
                        elementToAdd.insertAdjacentElement('afterend', lastCreatedInput);
                        if (group.params[params.length]) lastCreatedInput.value = group.params[params.length];
                        else group.params[params.length] = lastCreatedInput.value;
                    } else if (lastCreatedInput) {
                        lastCreatedInput.remove();
                        lastCreatedInput = null;
                        group.params.length--;
                    }
                    group.params[index] = newSelect.value;
                }
                newSelect.addEventListener('change', newSelectFunc);
                var elementToAdd = selectElement;
                while (elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend', newSelect);

                if (preserveValues) newSelect.value = group.params[index];
                else {
                    group.params[index] = newSelect.children[0].value;
                    newSelect.value = group.params[index];
                }
            } else if (param.type === 'text') {
                var newInput = document.createElement('input');
                newInput.classList.add('form-control');
                newInput.style.width = 'auto';
                if (group.params.length > index && preserveValues) newInput.value = group.params[index];
                newInput.addEventListener('change', function (e) {
                    group.params[index] = e.target.value;
                });
                var elementToAdd = selectElement;
                while (elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend', newInput);
                group.params[index] = newInput.value;
            } else if (param.type === 'multiline') {
                var textArea = document.createElement('textarea');
                textArea.classList.add('form-control');
                textArea.style.width = '500px';
                textArea.style.height = '100px';
                textArea.setAttribute('rows', 1);
                if (group.params.length > index && preserveValues) textArea.value = group.params[index];
                textArea.addEventListener('change', function (e) {
                    group.params[index] = e.target.value;
                });
                var elementToAdd = selectElement;
                while (elementToAdd.nextSibling)
                    elementToAdd = elementToAdd.nextSibling;
                elementToAdd.insertAdjacentElement('afterend', textArea);
                group.params[index] = textArea.value;
            }
        });
        newSelectFunc();
    } else
        group.params = [];
}

function renderGroup(group) {
    if (group.type === 'condition') {
        var divElement = document.createElement('div')
        var checkElement = document.createElement('input');
        var deleteButton = document.createElement('button');
        deleteButton.dataObj = group;
        deleteButton.innerText = 'X';
        deleteButton.addEventListener('click', function () {
            this.dataObj.parent.removeElement(this.dataObj);
            reRender();
        });
        deleteButton.classList.add('product-filtering-button');
        deleteButton.classList.add('button-red');
        deleteButton.style.margin = '5px';
        checkElement.type = 'checkbox';
        checkElement.dataObj = group;
        checkElement.classList.add("condition-box");


        var positiveSelectElement = groupExcludeSwitch.cloneNode(true);
        var groupId = generateId();
        positiveSelectElement.style.marginLeft = '8px';
        positiveSelectElement.style.marginRight = '8px';
        positiveSelectElement.querySelector('input').id = groupId;
        positiveSelectElement.querySelector('label').setAttribute('for', groupId);
        positiveSelectElement.querySelector('input').checked = parseInt(group.flag);
        positiveSelectElement.dataObj = group;


        var selectElement = conditionSelect.cloneNode(true);
        var originalOptions = Array.from(conditionSelect.children);
        var newOptions = Array.from(selectElement.children);
        for (var i = 0; i < originalOptions.length; i++)
            newOptions[i].params = originalOptions[i].params;
        selectElement.value = group.f;
        selectElement.dataObj = group;
        divElement.appendChild(checkElement);
        divElement.appendChild(positiveSelectElement);
        divElement.appendChild(selectElement);
        renderParams(selectElement, group, true);
        divElement.appendChild(deleteButton);
        selectElement.addEventListener('change', function (e) {
            this.dataObj.f = selectElement.value;
            renderParams(selectElement, group);
            divElement.appendChild(deleteButton);
        })
        positiveSelectElement.addEventListener('change', function (evt) {
            this.dataObj.flag = evt.target.checked ? 1 : 0;
        })
        divElement.classList.add('condition-div');
        group.htmlElement = divElement;
        return divElement;
    } else if (group.type === 'group') {
        var arr = [];
        var segmentDiv = document.createElement('div');
        segmentDiv.style.display = 'flex';
        segmentDiv.classList.add('condition-segment');

        var addButton = document.createElement('button');
        addButton.dataObj = group;
        addButton.innerText = 'ADD';
        addButton.addEventListener('click', function () {
            this.dataObj.addElement(new condition(__productFilterFunctions__[0].name, __productFilterFunctions__[0].params));
            reRender();
        });
        addButton.classList.add('product-filtering-button');
        addButton.classList.add('btn');
        addButton.classList.add('btn-primary');

        var checkElement = document.createElement('input');
        checkElement.type = 'checkbox';
        checkElement.dataObj = group;
        checkElement.classList.add('group-box');
        var selectElement = logicSelect.cloneNode(true);
        selectElement.value = group.operator;
        selectElement.dataObj = group;
        var positiveSelectElement = groupExcludeSwitch.cloneNode(true);
        var groupId = generateId();
        positiveSelectElement.style.marginLeft = '8px';
        positiveSelectElement.querySelector('input').id = groupId;
        positiveSelectElement.querySelector('label').setAttribute('for', groupId);
        positiveSelectElement.querySelector('input').checked = parseInt(group.flag);
        positiveSelectElement.dataObj = group;
        var logicDiv = document.createElement('div');
        logicDiv.appendChild(checkElement);
        logicDiv.appendChild(selectElement);
        logicDiv.appendChild(positiveSelectElement);
        //logicDiv.appendChild(addButton);
        logicDiv.style.display = 'flex';
        logicDiv.style.alignItems = 'center';

        selectElement.addEventListener('change', function () {
            this.dataObj.operator = selectElement.value;
        })

        positiveSelectElement.addEventListener('change', function (evt) {
            this.dataObj.flag = evt.target.checked ? 1 : 0;
        })

        var groupDiv = document.createElement('div');
        groupDiv.classList.add('condition-group');
        var generatedID = generateId();
        groupDiv.appendChild(addButton);
        var tempButton = document.getElementById('group-conditions').cloneNode(true); tempButton.style.display = '';
        groupDiv.appendChild(tempButton);
        tempButton = document.getElementById('remove-group').cloneNode(true); tempButton.style.display = '';
        groupDiv.appendChild(tempButton);
        tempButton = document.getElementById('ungroup-conditions').cloneNode(true); tempButton.style.display = '';
        groupDiv.appendChild(tempButton);
        group.elements.forEach(function (element) {
            groupDiv.appendChild(renderGroup(element));
        });

        Array.from(groupDiv.children).forEach(function (element, idx) {
            if (idx < 4) return;
            var childInput = element.querySelector("input");
            childInput.classList.add(generatedID);
            childInput.name = generatedID;
            childInput.addEventListener('click', function () {
                resetCheckInputs(childInput.name);
            });
        });

        segmentDiv.appendChild(logicDiv);
        segmentDiv.appendChild(groupDiv);

        group.htmlElement = segmentDiv;
        return segmentDiv;
    }
}

function groupConditions(curElement) {
    var parent;
    var render = false;
    var elements = Array.from(document.querySelectorAll('.condition-box:checked,.group-box:checked')).map(function (element) {
        parent = element.dataObj.parent;
        element.dataObj.parent.removeElement(element.dataObj, true);
        render = true;
        return element.dataObj;
    });
    if (!render)
        return;
    var newGroup = new group('OR', ...elements);
    parent.addElement(newGroup);
    reRender();
}

function removeGroup(curElement) {
    Array.from(document.querySelectorAll('.group-box:checked')).forEach(function (element) {
        element.dataObj.parent.removeElement(element.dataObj);
    });
    reRender();
}

function ungroupConditions(curElement) {
    Array.from(document.querySelectorAll('.group-box:checked')).forEach(function (element) {
        element.dataObj.elements.forEach(function (el) {
            element.dataObj.parent.addElement(el);
        });
        element.dataObj.parent.removeElement(element.dataObj);
    });
    reRender();
}