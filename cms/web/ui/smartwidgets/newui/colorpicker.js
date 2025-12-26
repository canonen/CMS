function rgbaColorPicker(elementSelector, defaultColor)
{
    
    function hexToRGBA(hexCode) {
        var temp="";
        if(hexCode.length !== 3 && hexCode.length !== 6)
            throw new Error('invalid hex code');
        if(hexCode.length === 3) {
            var tempCode = "";
            for(var i=0;i<3;i++) {
                tempCode += hexCode[i] + hexCode[i];
            }
            hexCode = tempCode;
        }
        for(var i=0;i<6;i+=2) {
            temp+=parseInt(hexCode[i] + hexCode[i+1],16) + ',';
        }
        return 'rgba(' + temp + '1)';
    }
    
    if(defaultColor && defaultColor.substr(0,4) !== 'rgba')
        throw new Error('invalid rgba code');

    function filterMousePosition(evt, element){
        var dimensions = element.getBoundingClientRect();
        return { x: Math.floor(evt.clientX - dimensions.left),
                 y : Math.floor(evt.clientY - dimensions.top)
        }
    }

    var flexDiv = document.createElement('div');
    flexDiv.style.display = 'flex';
    flexDiv.style.flexDirection = 'column';
    flexDiv.style.width = '200px';

    var colorPreviewDiv = document.createElement('div');
    colorPreviewDiv.style.display = 'flex';
    
    var colorPreview = document.createElement('canvas');
    colorPreview.width = '50';
    colorPreview.height = '20';
    colorPreview.style.width = '50px';
    colorPreview.style.border = '1px solid';
    colorPreview.style.cursor = 'pointer';
    colorPreview.style.backgroundColor = 'white';
    
    var colorInput = document.createElement('input');
    colorInput.style.width = '120px';
    colorInput.style.marginLeft = '5px';
    colorInput.style.fontSize = '12px';
    
    colorPreviewDiv.appendChild(colorPreview);
    colorPreviewDiv.appendChild(colorInput);

    var colorGradient = document.createElement('canvas');
    colorGradient.style.cursor = 'crosshair';
    colorGradient.width = '200';
    colorGradient.height = '150';

    var colorPicker = document.createElement('canvas');
    colorPicker.style.cursor = 'crosshair';
    colorPicker.width = '200';
    colorPicker.height = '20';

    var alphaPicker = document.createElement('canvas');
    alphaPicker.style.cursor = 'crosshair';
    alphaPicker.width = '200';
    alphaPicker.height = '20';
    alphaPicker.style.backgroundColor = 'white';

    document.querySelector(elementSelector).appendChild(flexDiv);

    flexDiv.appendChild(colorPreviewDiv);
    colorPreviewDiv.insertAdjacentElement('afterend', colorGradient);
    colorGradient.insertAdjacentElement('afterend', colorPicker);
    colorPicker.insertAdjacentElement('afterend', alphaPicker);
    var ctx1 = colorGradient.getContext('2d');
    var ctx2 = colorPicker.getContext('2d');
    var ctx3 = alphaPicker.getContext('2d');
    var ctx4 = colorPreview.getContext('2d');


    var alpha = 1;
    var color = {
        color: 'rgba(255,0,0,1)',
        setColor: function(color) {
            this.color = color;
            ctx4.clearRect(0,0,colorPreview.width,colorPreview.height);
            ctx4.strokeStyle = 'grey';
            ctx4.moveTo(0,colorPreview.height/2);
            ctx4.lineTo(colorPreview.width,colorPreview.height/2);
            ctx4.moveTo(colorPreview.width/2,0);
            ctx4.lineTo(colorPreview.width/2,colorPreview.height);
            ctx4.stroke();
            ctx4.fillStyle = color;
            ctx4.fillRect(0,0,colorPreview.width,colorPreview.height);
            alpha = parseFloat(color.split('(')[1].split(',')[3]);
            colorInput.value = color;
        }
    }

    if(defaultColor) {
        color.setColor(defaultColor);
        fillGradient(defaultColor);
    } else {
        color.setColor(color.color);
        fillGradient(color.color);
    }

    var elements = {
        show: true,
        toggle() {
            if(this.show) {
                colorGradient.style.display = 'none';
                colorPicker.style.display = 'none';
                alphaPicker.style.display = 'none';
                this.show = false;
            } else {
                colorGradient.style.display = 'block';
                colorPicker.style.display = 'block';
                alphaPicker.style.display = 'block';
                this.show = true;
            }
        }
    }

    elements.toggle();

    colorPreview.addEventListener('click', function() {
        if(colorInput.hasAttribute('disabled')) {
            return;
        }
        elements.toggle();
    });

    var drag = false;
    var alphaDrag = false;
    var colorPickerDrag = false;
    
    colorInput.addEventListener('change', function(e) {
        var hexCode = e.target.value;
        try {
            if(hexCode.substr(0,5) === 'rgba(')
                color.setColor(hexCode);
            else
                color.setColor(hexToRGBA(hexCode));
            if(elements.callback)elements.callback.call(this, color.color);
        } catch(exc) {
            e.target.value = color.color;
        }
    });

    colorGradient.addEventListener('mousedown',function(){
        drag = true;
    });

    colorGradient.addEventListener('mouseup',function(){
        drag = false;
        //if(elements.callback)elements.callback.call(this, color.color);
    });

    alphaPicker.addEventListener('mousedown',function(){
        alphaDrag = true;
    });

    alphaPicker.addEventListener('mouseup',function(){
        alphaDrag = false;
        //if(elements.callback)elements.callback.call(this, color.color);
    });

    colorPicker.addEventListener('mousedown',function(){
        colorPickerDrag = true;
    });

    colorPicker.addEventListener('mouseup',function(){
        colorPickerDrag = false;
    });

    colorGradient.addEventListener('mousemove', function(e) {
        if(!drag)
            return;
        var pos = filterMousePosition(e, this);
        var imageData = ctx1.getImageData(pos.x,pos.y,1,1);
        color.setColor('rgba('+imageData.data[0]+','+imageData.data[1]+','+imageData.data[2]+','+alpha+')');
    });

    colorGradient.addEventListener('click', function(e) {
        var pos = filterMousePosition(e, this);
        var imageData = ctx1.getImageData(pos.x,pos.y,1,1);
        color.setColor('rgba('+imageData.data[0]+','+imageData.data[1]+','+imageData.data[2]+','+alpha+')');
        if(elements.callback)elements.callback.call(this, color.color);
    });

    colorPicker.addEventListener('mousemove', function(e) {
        if(!colorPickerDrag)
            return false;
        var pos = filterMousePosition(e, this);
        var imageData = ctx2.getImageData(pos.x,pos.y,1,1);
        fillGradient('rgb('+imageData.data[0]+','+imageData.data[1]+','+imageData.data[2]+')');
    });

    colorPicker.addEventListener('click', function(e) {
        var pos = filterMousePosition(e, this);
        var imageData = ctx2.getImageData(pos.x,pos.y,1,1);
        fillGradient('rgb('+imageData.data[0]+','+imageData.data[1]+','+imageData.data[2]+')');
    });

    alphaPicker.addEventListener('mousemove', function(e) {
        if(!alphaDrag)
            return false;
        var pos = filterMousePosition(e, this);
        var imageData = ctx3.getImageData(pos.x,pos.y,1,1);
        alpha = (imageData.data[3]/255).toFixed(2);

        if(alpha>=0.98)
            alpha=1;
        else if(alpha<=0.02)
            alpha=0;
        var imageData = color.color.split('(')[1].split(',');
        color.setColor('rgba('+imageData[0]+','+imageData[1]+','+imageData[2]+','+alpha+')');
    });

    alphaPicker.addEventListener('click', function(e) {
        var pos = filterMousePosition(e, this);
        var imageData = ctx3.getImageData(pos.x,pos.y,1,1);
        alpha = (imageData.data[3]/255).toFixed(2);

        if(alpha>=0.98)
            alpha=1;
        else if(alpha<=0.02)
            alpha=0;
        var imageData = color.color.split('(')[1].split(',');
        color.setColor('rgba('+imageData[0]+','+imageData[1]+','+imageData[2]+','+alpha+')');
        if(elements.callback)elements.callback.call(this, color.color);
    });

    ctx2.rect(0, 0, colorPicker.width, colorPicker.height);
    var grd1 = ctx2.createLinearGradient(0, 0, colorPicker.width, 0);
    grd1.addColorStop(0, 'rgba(255, 0, 0, 1)');
    grd1.addColorStop(0.17, 'rgba(255, 255, 0, 1)');
    grd1.addColorStop(0.34, 'rgba(0, 255, 0, 1)');
    grd1.addColorStop(0.51, 'rgba(0, 255, 255, 1)');
    grd1.addColorStop(0.68, 'rgba(0, 0, 255, 1)');
    grd1.addColorStop(0.85, 'rgba(255, 0, 255, 1)');
    grd1.addColorStop(1, 'rgba(255, 0, 0, 1)');
    ctx2.fillStyle = grd1;
    ctx2.fill();

    ctx3.rect(0, 0, alphaPicker.width, alphaPicker.height);
    var grd2 = ctx3.createLinearGradient(0, 0, alphaPicker.width, 0);
    grd2.addColorStop(0, 'rgba(0,0,0,0)');
    grd2.addColorStop(1, 'rgba(0,0,0,1)');
    ctx3.fillStyle = grd2;
    ctx3.fill();

    function fillGradient(rgbColor) {
      ctx1.fillStyle = rgbColor;
      ctx1.fillRect(0, 0, colorGradient.width, colorGradient.height);

      var grdWhite = ctx2.createLinearGradient(0, 0, colorGradient.width, 0);
      grdWhite.addColorStop(0, 'rgba(255,255,255,1)');
      grdWhite.addColorStop(1, 'rgba(255,255,255,0)');
      ctx1.fillStyle = grdWhite;
      ctx1.fillRect(0, 0, colorGradient.width, colorGradient.height);

      var grdBlack = ctx2.createLinearGradient(0, 0, 0, colorGradient.height);
      grdBlack.addColorStop(0, 'rgba(0,0,0,0)');
      grdBlack.addColorStop(1, 'rgba(0,0,0,1)');
      ctx1.fillStyle = grdBlack;
      ctx1.fillRect(0, 0, colorGradient.width, colorGradient.height);
    }

    return {
        getColor: function() {
            return color.color;
        },
        color: color,
        setListener: function(callback) {
			elements.callback = callback;
		},
        setEnabled: function(status) {
            if(status) {
                colorInput.removeAttribute('disabled');
            } else {
                colorInput.setAttribute('disabled','');
                if(elements.show)elements.toggle();
            }
        }
    };

}