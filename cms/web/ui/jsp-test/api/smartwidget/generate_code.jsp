<html lang="en">
<body>
<script>

    if(!window['rvtsPopupArray'])
        window['rvtsPopupArray'] = [];
    rvtsPopupArray.push({rvts_customer_id:'<rvts_customer_id>'});
    (function() {
        var _rTag = document.getElementsByTagName('script')[0];
        var _rcTag = document.createElement('script');
        _rcTag.type = 'text/javascript';
        _rcTag.async = 'true';
        _rcTag.src = ('https://<rvts_customer_name>.revotas.com/trc/smartwidget/smartwidget.js');
        _rTag.parentNode.insertBefore(_rcTag, _rTag);
    })();
</script>
</textarea>
<script>
    document.getElementById('html-code').value = document.getElementById('html-code').value.replace('<rvts_customer_id>',window.opener.customerId);
    document.getElementById('html-code').value = document.getElementById('html-code').value.replace('<rvts_customer_name>',window.opener.custName.toLowerCase());
</script>
</body>
</html>