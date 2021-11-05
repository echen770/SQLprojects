use ebay
go

merge [2016] AS tgt
USING [2017] AS src
	ON (src.[transaction id] = tgt.[transaction id])
	WHEN not MATCHED then
		INSERT ([paid date], [item id], [transaction id], charity, amount, status) 
		VALUES (src.[paid date], src.[item id], src.[transaction id], src.charity, src.amount, src.status);

merge [2016] AS tgt
USING [2018] AS src
	ON (src.[transaction id] = tgt.[transaction id])
	WHEN not MATCHED then
		INSERT ([paid date], [item id], [transaction id], charity, amount, status) 
		VALUES (src.[paid date], src.[item id], src.[transaction id], src.charity, src.amount, src.status);

merge [2016] AS tgt
USING [2019] AS src
	ON (src.[transaction id] = tgt.[transaction id])
	WHEN not MATCHED then
		INSERT ([paid date], [item id], [transaction id], charity, amount, status) 
		VALUES (src.[paid date], src.[item id], src.[transaction id], src.charity, src.amount, src.status);

merge [2016] AS tgt
USING [2020] AS src
	ON (src.[transaction id] = tgt.[transaction id])
	WHEN not MATCHED then
		INSERT ([paid date], [item id], [transaction id], charity, amount, status) 
		VALUES (src.[paid date], src.[item id], src.[transaction id], src.charity, src.amount, src.status);

merge [2016] AS tgt
USING [2021] AS src
	ON (src.[transaction id] = tgt.[transaction id])
	WHEN not MATCHED then
		INSERT ([paid date], [item id], [transaction id], charity, amount, status) 
		VALUES (src.[paid date], src.[item id], src.[transaction id], src.charity, src.amount, src.status);