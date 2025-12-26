function fix_all_dates()
{
	fix_all_start_dates();
	fix_queue_date();
}

function fix_all_start_dates()
{
	fix_sample_start_date('');
	var cq = FT.camp_qty.value;
	for(i=1;i<=cq;i++)
	{
		fix_sample_start_date(i);
	}
}

function fix_sample_start_date(sample_id)
{
	var sds = eval('FT.start_date_switch' + sample_id);

	if(sds==null) return;

	var sd = eval('FT.start_date' + sample_id);

	if(sds[0].checked) sd.value = '';
	else
	{
		var y = eval('FT.start_date_year' + sample_id);
		var m = eval('FT.start_date_month' + sample_id);
		var d = eval('FT.start_date_day' + sample_id);
		var h = eval('FT.start_date_hour' + sample_id);
		sd.value = y.value + '-' + m.value + '-' + d.value + ' ' + h.value + ':00';
	}
}


function fix_queue_date()
{
	var qds = FT.queue_date_switch;
	var qd = FT.queue_date;

	if(qds[0].checked) qd.value = '';
	else
	{
		var y = FT.queue_date_year;
		var m = FT.queue_date_month;
		var d = FT.queue_date_day;
		var h = FT.queue_date_hour;
		qd.value = y.value + '-' + m.value + '-' + d.value + ' ' + h.value + ':00';
	}
}
