* impact evaluation with matching
* simulation: training program for young adults, effects on their wages

clear 
set seed 3487106

* MC simulations for impact estimation 

clear 
global N = 1000
global times = 200

set obs $times
gen diff_post = .
*gen n_on_support = .
gen ddiff = .
gen diff_post_v2 = .
*gen n_on_support_v2 = .


save "results", replace 

qui {
	forv i = 1/$times {
		clear 
		
		noi di ""
		noi di ""
		noi di "run: `i'"

		set obs $N 
		
		gen female = (uniform() <= 0.4)
		gen age = ceil(18+uniform()*7)
		gen education_latent = uniform()
		gen education = 1 if education_latent <= 0.15
		replace education = 2 if education_latent > 0.15 & education_latent <= 0.65
		replace education = 3 if education_latent > 0.65 & education_latent <= 1
		gen motivation = rnormal() //unobservable 
		gen epsilon = rnormal()
		gen treated = (motivation > 0) //there is selection bias

		gen wage_pre = ceil(1500 - 100*female + 20*age + 10*education_latent +20*motivation + epsilon) //omitted variable problem
		gen wage_post = wage_pre + 200 if treated == 1 //true impact = 200
		replace wage_post = wage_pre if treated == 0

		dtable i.female age i.education wage_pre, by(treated, tests) // clearly the 2 groups are not balanced on wage_pre 

		* matching on background variables (over-estimation)
		psmatch2 treated i.female age i.education, common kernel out(wage_post)
		*psgraph

		* impact estimation derivation
		rename _wage_post counterfactual
		gen diff_post = wage_post - counterfactual if !missing(counterfactual)
		qui sum diff_post if !missing(counterfactual)
		global diff_post = r(mean) 
		noi di "diff_post:"
		noi di $diff_post //same as ATT (over-estimation)

		* matching on background variables + did
		gen diff_pre = wage_pre - counterfactual if !missing(counterfactual)
		qui sum diff_pre if !missing(counterfactual)
		global diff_pre = r(mean)
		global ddiff = $diff_post - $diff_pre
		noi di "ddiff:"
		noi di $ddiff //same as true impact

		* matching on background variables & wage_pre
		drop counterfactual diff_post 
		psmatch2 treated i.female age i.education wage_pre, common kernel out(wage_post)
		*psgraph

		rename _wage_post counterfactual
		gen diff_post = wage_post - counterfactual if !missing(counterfactual)
		qui sum diff_post if !missing(counterfactual)
		global diff_post_v2 = r(mean)  
		noi di "diff_post_v2"
		noi di $diff_post_v2 //same as ATT (close to real impact but many off-support!)


		use "results", clear 
		replace diff_post = $diff_post in `i'
		*replace n_on_support = $n_on_support in `i'
		replace ddiff = $ddiff in `i'
		replace diff_post_v2 = $diff_post_v2 in `i'
		*replace n_on_support_v2 = $n_on_support_v2 in `i'

		save "results", replace 
	}
}


sum diff_post ddiff diff_post_v2


