* ==============================================================================
* right-tailed unit root test
* ==============================================================================
* import data

* btc close
import excel "C:\Users\geodo\Desktop\2021-2\계량경제학세미나\econ_semi_data\BTC.xlsx", sheet("Sheet1") firstrow

* TSLA close
import excel "C:\Users\geodo\Desktop\2021-2\계량경제학세미나\econ_semi_data\TSLA.xlsx", sheet("Sheet1") firstrow

drop if A < 755
* ------------------------------------------------------------------------------
* python data pre-processing

gen date_1=date(date, "YMD")
format date_1 %td
format %tdCCYY-NN-DD date_1

drop Date date A
rename date_1 date

gen N =[_n]

tsset date, format(%tdCCYY-NN-DD)
* ------------------------------------------------------------------------------
* log transformation

gen lClose=ln(Close)
gen dClose=lClose[_n]-lClose[_n-1]
* ------------------------------------------------------------------------------
* rolling sample

drop Open High Low Volume Change
order N date Close lClose dClose

* set the directory
pwd
cd C:\Users\geodo\Desktop\2021-2\계량경제학세미나\hw8\temp data
dir

* raw: lClose

    * rolling method

	forvalue i=1/678{
	preserve
	
	keep if N >= `i' & N < `i' + 365
	
	dfuller lClose, drift lag(10) regress
	display r(Zt)
	gen ADF = r(Zt)
	gen window_n =.
	replace window_n = date[365]
	format %tdCCYY-NN-DD window_n
	
	save temp`i'.dta, replace
	
	restore
	}
	
	clear all
	use "C:\Users\geodo\Desktop\2021-2\계량경제학세미나\hw8\temp data\temp1.dta"
	
	forvalue i=2/678{
    append using temp`i'
	}

	* recursive method
	
	forvalue i=1/678{
	preserve
	
	keep if N >= 1 & N < `i' + 365
	
	dfuller lClose, drift lag(10) regress
	display r(Zt)
	gen ADF = r(Zt)
	gen window_n =.
	replace window_n = date[`i'+364]
	format %tdCCYY-NN-DD window_n
	
	save temp`i'.dta, replace
	
	restore
	}
	
	clear all
	use "C:\Users\geodo\Desktop\2021-2\계량경제학세미나\hw8\temp data\temp1.dta"
	
	forvalue i=2/678{
    append using temp`i'
	}

order window_n N date Close lClose dClose

set scheme s1mono

egen Sup_ADF = max(ADF)

gen CV_5 =.
replace CV_5 = -0.08
gen Sup_CV_5 =.
replace Sup_CV_5 = 1.468

gen CV_1 =.
replace CV_1 = 0.60
gen Sup_CV_1 =.
replace Sup_CV_1 = 2.094

twoway line ADF window_n, lcolor(black) || line Sup_CV_1 window_n, lcolor(red) || line Sup_CV_5 window_n, lcolor(red) ytitle("ADF-Statistics") xtitle("Period") legend(label(1 "ADF-Statistics") label(2 "Sup CV(0.01)") label(3 "Sup CV(0.05)")) note("Source: Phillips et al.(2011)")
* ------------------------------------------------------------------------------
* reference

* phillips et al.(2011)
* explosive behabior in the 1990s NASDAQ: when did exuberance escalate asset values?
* ==============================================================================