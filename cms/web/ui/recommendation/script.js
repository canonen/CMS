var typeList = {
    '50': 'Top Seller',
    '60': 'Price Drop',
    '70': 'New Product',
    '80': 'Back in Stock',
    '90': 'Buy Also',
    '100': 'Similar',
    '110': 'You Might',
    '120': 'View Also',
    '130': 'Recently Viewed',
    '140': 'Trending'
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

var config = [{
    type: '50',
    selector: 'rvts_top_seller',
    title: 'Top Seller',
    cssInput: '',
    limit: '10',
    rcp: rcp_url
}];

var currentConfig;
var currentInput;
var cssWindow;

function closePopup() {
    cssWindow.close();
}

function renderTypes() {
    var select = document.createElement('select');
    for(var type in typeList) {
        var option = document.createElement('option');
        option.value = type;
        option.innerText = typeList[type];
        select.appendChild(option);
    }
    return select;
}

function renderConfigs() {
    var inputGroups = config.map(function(element,index) {
        var inputGroup = document.createElement('div');
        inputGroup.classList.add('input-group');
        inputGroup.innerHTML = '<button id="delete-config-'+index+'" class="recommendation-button" style="position:absolute;top:-15px;right:2px;width:20px;height:20px;line-height:10px;">X</button>';

        var inputSubGroup = document.createElement('div');
        inputSubGroup.classList.add('input-subgroup');
        inputSubGroup.innerHTML = '<label class="widget-control label" for="type-'+index+'">Type</label>';
        
        var typeSelect = renderTypes();
        typeSelect.id = 'type-' + index;
        typeSelect.classList.add('widget-control');
        typeSelect.classList.add('config-select');
        typeSelect.value = element.type;
        
        inputSubGroup.appendChild(typeSelect);

        inputGroup.appendChild(inputSubGroup);

        var emptyGroup = document.createElement('div');
        emptyGroup.classList.add('group'); 
        
        var typeLabel = document.createElement('label')

        var selector = emptyGroup.cloneNode();
        selector.innerHTML = '<input value="'+(element.selector ? element.selector : '')+'" class="widget-control form-input text-input" id="recommendation-selector-'+index+'" type="text"/> <label class="widget-control form-input-label" for="recommendation-selector-'+index+'">Selector</label>';
        inputSubGroup.appendChild(selector);

        var title = emptyGroup.cloneNode();
        title.innerHTML = '<input value="'+(element.title ? element.title : '')+'" class="widget-control form-input text-input" id="recommendation-title-'+index+'" type="text"/> <label class="widget-control form-input-label" for="recommendation-title-'+index+'">Title</label>';
        inputSubGroup.appendChild(title);
        title.children[0].addEventListener('change', function(e) {
            element.title = e.target.value;
        })
        
        var cssInput = emptyGroup.cloneNode();
        if(element.cssInput) {
            try {
                element.cssInput = decodeURIComponent(element.cssInput);
            } catch(e) {
                
            }
            cssInput.innerHTML = '<textarea style="resize:none;" rows="1" class="widget-control form-input text-input" readonly>'+element.cssInput+'</textarea><label class="widget-control form-input-label shrink" for="recommendation-css-input-'+index+'">Css Input</label>'
        } else {
            fetch('template.css').then(function(resp) {return resp.text();}).then(function(resp) {
                resp = resp.split('rvts_top_seller').join(element.selector);
                element.cssInput = resp;
                cssInput.innerHTML = '<textarea style="resize:none;" rows="1" class="widget-control form-input text-input" readonly>'+element.cssInput+'</textarea><label class="widget-control form-input-label shrink" for="recommendation-css-input-'+index+'">Css Input</label>'
            });
        }
        inputSubGroup.appendChild(cssInput);
        cssInput.addEventListener('click', function() {
            currentConfig = element;
            currentInput = cssInput;
            var width = 500;
            var height = 300;
            var left = (screen.width/2)-(width/2);
            var top = (screen.height/2)-(height/2);
            cssWindow = window.open("./css_editor.html", "CSS Editor", "height="+height+",width="+width+",left="+left+",top="+top);
        })
        
        var selectorState = (function () {
            var oldValue = '';
            var newValue = '';
            return {
                setOld: function(value) {oldValue=value;},
                setNew: function(value) {newValue=value;},
                getOld: function() {return oldValue;},
                getNew: function() {return newValue;}
            }
        })();
        
        selector.children[0].addEventListener('focus', function(e) {
            selectorState.setOld(e.target.value);
        }, true);
        selector.children[0].addEventListener('change', function(e) {
            selectorState.setNew(e.target.value);
            element.selector = e.target.value;
            element.cssInput = element.cssInput.split(selectorState.getOld()).join(selectorState.getNew());
            cssInput.children[0].innerHTML = element.cssInput;
        })
        
        var categoryId = emptyGroup.cloneNode();
        categoryId.innerHTML = '<input value="'+(element.categoryId ? element.categoryId : '')+'" class="widget-control form-input text-input" id="recommendation-category-id-'+index+'" type="text"/> <label class="widget-control form-input-label" for="recommendation-category-id-'+index+'">Category Id</label>';
        inputSubGroup.appendChild(categoryId);
        categoryId.children[0].addEventListener('change', function(e) {
            element.categoryId = e.target.value;
        })

        var limit = emptyGroup.cloneNode();
        limit.innerHTML = '<input value="'+(element.limit ? element.limit : '')+'" class="widget-control form-input text-input" id="recommendation-limit-'+index+'" type="text"/> <label class="widget-control form-input-label" for="recommendation-limit-'+index+'">Limit</label>';
        inputSubGroup.appendChild(limit);
        limit.children[0].addEventListener('change', function(e) {
            element.limit = e.target.value;
        })
        
        typeSelect.addEventListener('focus', function(e) {
            selectorState.setOld(selector.children[0].value);
        })
        
        typeSelect.addEventListener('change', function(e) {
            selectorState.setNew(queryList[e.target.value]);
            element.cssInput = element.cssInput.split(selectorState.getOld()).join(selectorState.getNew());
            cssInput.children[0].innerHTML = element.cssInput;
            element.type = e.target.value;
            element.selector = queryList[e.target.value];
            selector.children[0].value = element.selector;
            selector.children[0].focus();
        });

        inputGroup.querySelector('#delete-config-' + index).addEventListener('click', function() {
            var answer = confirm('Are you sure you want to delete selected config?');
            if(answer) {
                config = config.filter(function(element,idx) {return index != idx});
                renderConfigs(config);
            }
        });
        
        return inputGroup;
    });
    
    var controlPanel = document.querySelector('.control-panel');
    controlPanel.innerHTML = '';
    inputGroups.forEach(function(element) {
        controlPanel.appendChild(element);
    });
    
    Array.from(document.querySelectorAll("input.text-input")).forEach(function(element) {
        var el = document.querySelector('label[for='+element.id+']');
        if(element.value) el.classList.add('shrink');
        element.addEventListener('change',function(e){
            if(e.target.value) el.classList.add('shrink');
            else el.classList.remove('shrink');
        });
    });
}

renderConfigs(config);

document.getElementById('new').addEventListener('click', function() {
    fetch('template.css').then(function(resp) {return resp.text();}).then(function(resp) {
        config.push({
            type: '50',
            selector: 'rvts_top_seller',
            title: 'Top Seller',
            cssInput: resp,
            limit: '10',
            rcp: rcp_url
        })
        renderConfigs(config);
    });
});
