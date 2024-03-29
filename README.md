# PS Matching
## Project objective
In this project I imagine a policy evaluation application and I apply PS Matching using Monte-Carlo simulations.  
The primary aim is to show that PS Matching combined with DiD is a powerful approach to estimate the impact of a policy when there is not a clear assignment rule to the treatment (like randomization or ranking) while accounting for unobservable variables constant over time. This method is able to correct for selection bias and outperforms PS Matching using background characteristics and baseline outcome levels. 

## Case study and Data
Suppose we want to evaluate the impact of a training program on the earnings of young individuals in a given country. 
We suppose that individuals with higher levels of motivation are more likely to apply. Therefore there exists a selection bias based on an unobservable variable (motivation). We suppose that motivation is constant over time.
   
We generate a dataset and we estimate the policy impact in three different ways: 
1. PS Matching on solely backgroung characteristics
2. PS Maching combined with DiD
3. PS Matching on background characteristics and baseline outcome levels.

We perform this procedure multiple times (MC simulations) and for each method we compute the mean among all the estimated impacts. Finally, we compare the final results and we draw our conclusions.

In this project, the key variables are the following ones:
* female: binary variable that equals 1 for females and 0 for males
* age: numeric variable ranging from 18 to 25 years
* latent education: numeric variable from 0 to 1 indicating education score, with higher scores denoting higher education levels. We then categorize this variable into three levels (1 to 3) representing low, medium and high educational levels.
* motivation: unobservable numeric variable that follows a normal distribution. This variable is used to generate outcome variables but is omitted when applying the three methods to estimate the impact of the program
* treated: binary variable that takes the value 1 for individuals participating in the program (those with motivation levels above the mean equal to 0) and 0 otherwise

The outcome variable of interest is wage. We first compute wage at baseline level as a function of individual explanatory variables (observable or not) plus a random error term ϵ (representing any "out of control" factor affecting wages like good/bad luck) with this equation:

` gen wage_pre = ceil(1500 - 100*female + 20*age + 10*education_latent +20*motivation + epsilon)  `

We suppose that the true impact of the training program is a wage increase of
200 units. Therefore we generate the wages at endline level with these equations:

` gen wage_post = wage_pre + 200 if treated == 1 `
 
` replace wage_post = wage_pre if treated == 0 `



## Results and Conclusions
In this section, we compare the results obtained with the three methods mentioned above running MC simulations. 

![image](https://github.com/BenedettaValpreda/PS_Matching/assets/147848856/8470f799-48a9-4fce-9e6e-b4a871c50fea)

As expected, we can see that Method1 (raw PS-Matching on background characteristics) provides a biased estimation of the treatment effect. Method2 (PS-Matching combined with DiD) is able to correct the bias and gives the exact true impact. Method3 (PS-Matching on background plus baseline outcome) closely approximates the true effect but only in mean. 

In conclusion, the combination of PS-Matching and DiD offers a powerful approach to address selection bias and account for unobservable invariant factors in policy evaluation. By providing reliable estimates of policy impacts, this method can contribute to more informed decision-making processes in various policy settings.

For further details see the Stata script and the pdf report for this project in this directory.
