Original: https://docs.google.com/spreadsheets/d/1tSrEGpvg19OMKrRg45HGvsZBGz8BkeVc/edit?pli=1#gid=1841057518 (view only)

<img width="1016" alt="Screenshot 2023-09-04 at 5 56 01 PM" src="https://github.com/mindyng/2023-Business-Projects/assets/12889138/7bb6ad1a-4a9b-4616-bb0a-8a4e610d59c8">

(Problems B-D were omitted)

Problem A:

<img width="1147" alt="Screenshot 2023-09-04 at 5 57 11 PM" src="https://github.com/mindyng/2023-Business-Projects/assets/12889138/c236eb19-04ce-4ce7-b612-e2969e37cee3">

Problem E:

<img width="911" alt="Screenshot 2023-09-04 at 5 58 15 PM" src="https://github.com/mindyng/2023-Business-Projects/assets/12889138/af45fbaf-0e22-4996-849d-10d95d2d91e6">

__________________________________________________________________________________________________________

RESPONSE:

Initial visualization with given data: 

Given monthly user funnel, would like to graph the rates as a time series. (have ratio of total current step in funnel over total previous step in funnel). Calculate MoM conversion rate (current month - previous month/previous month)

Other data that would help deepen insights and allow for discernment with choosing recommended experiments:

Event data just gives action information from user. In order to generate insights, would need to see what each event properties there are to see get more context to that event . For example, when a user signs up for the GoJek app, this is information we can gather when completing any of the funnel actions: 

	1. Acquisition Source: Where did user get push to sign up (online/offline)
	2. Device type: phone OS
	3. Time they signed up
	4. Demographic: gender, language, race, geography
	5. Persona: cut users based on specific behaviors related to analysis
	6. Product Categories: company-determined user categories within the product (driver/rider/both)

Challenge:

To systematically go through these problems, examine the goal and analyze/brainstorm what is preventing this goal from happening. And keep asking Why's to get to the root cause to get ideas for how to solve user frustration.

	1. Maximize the number of active users on the Go-Jek platform:
		1. Determine which are the most frequent friction points/arduous paths to conversion
		2. Plan out 3 scrappy way to solve for issue and create Most viable prototype with least amount of resources used
		3. Set up experiment and see what users' response are to change in journeys
		4. If stat sig with test stat < p-value with alpha at 0.05 then implement change to specific cohort/user base
		5. Able to acquire more users also by looking at different geography, household income, different use case within a cohort (not just delivering people, but also delivering food, goods, anything that can be brought from point A to point B)  
	2. Increase the frequency of usage for each user on the Go-Jek platform
		1. Would warn against discounts/free voucher because detracts away from product solving solution (causes noise)
		2. Examine what are the friction points
		3. Look at what other problems can product solve that Go-Jek has not been aware of yet and build MVP, test it and see if increases user engagement 

A lot of ideas will flow out from user research, so need to determine where to focus efforts by measuring opportunity costs. However, if able to run scrappy, low cost experiments all at once to get users' response quickly then opportunity cost calculations may not be necessary. At minimum, calculate what would be the potential uptick in revenue considering implementation and maintenance costs of new feature in attempt to change user behavior. 

• Opportunity Cost = Return on Most Profitable Investment Choice - Return on Investment Chosen to Pursue
• Look at success probability 

However, opportunity cost is also an important issue to be considered. We need to also understand if that net benefit, whatever it is, does outweigh any other potential net benefit of an alternative strategy we might pursue instead.

Example of Calculating Opportunity Costs based on Funnel:

Reference:  https://almanac.io/docs/process-prioritizing-growth-experiments-513f257a2571983772919a92fa05da69

![image](https://github.com/mindyng/2023-Business-Projects/assets/12889138/3b283303-d17e-4106-a4b7-a5afe2812b4c)

Solution:

This will be based on which experiments were successful with statistical significance. A/B testing allows for elimination of random chance, determining causality. Careful with: Endogeneity- independent variable correlation with dependent variable unattributable because of unknown effect (used in: cause and effect in multivariate conditions); misattributing impact of experiment if not controlling for all variables. So make sure all possible effects from product change are being measured/accounted for when defining success, stretch and guardrail metrics.

Whether or not the solution is actionable would have been determined during experiment generation phase. It would be the step before determining which experiments to prioritize (by possibly calculating opportunity costs). Actionable means that users' behavior will change based on specific change to product. 

* Short-term execution plan is based on UX, Eng, Analytics team coming together to build MVP (prototype).

* Long-term plan execution plan involves: if experiment shows statistical significant results, how to build out possible full-fledged MVP and/or addressing  non-expected insights gained from conducting experiments.

* Able to determine if solution represents actual opportunity/problem being solved by calculating opportunity costs and creating success forecasts using data about current state of users' behaviors (negative), specific metrics related to users' friction points. Examine closely the ROI and maximize it - with little company resources, how can we see the greatest uptick in active users and engagement.

To really determine if this solution represents an actual opportunity/solves a problem is by releasing new features in the wild and seeing if it changes users' behavior by performing A/B Test.

Problem E:

New Product Feature - Content Feed made in order to increase # of transactions

Hypothesis: Adding Content Feed with strategic product placements will increase engagement and therefore increase propensity of user to convert using different Go-Jek services

Experiment Design:

- Ho (Control): Group that is exposed to status quo home page without content feed
- Ha: Test Group is exposed to home page with content feed with product placements

• Calculate power in order to determine sample size
• Once get sample size, can determine how long to run experiment based on traffic (100000/day but need 1000000 users to reach power then 10 days/2 weeks to reach proper sample size to get stat sig result)
• random sampling

Metrics to measure

- Success: increase transactions
- Stretch: increase LTV
- Guardrail: Engagement

Insights:

• Who is using the feed the most?
• Who is just engaging with the feed?
• Who is on the feed and presses on a product icon?
• What is the usual amount of time spent on feed?
• What is the usual amount of time spent to go from feed to product icon?
• At what time is the feed usually used?
• When do people usually drop off from feed?
• How many drop off from product Go-Tix/Go-Pulsa after coming from feed vs not coming from feed?

Analyzing Experiment:

Look at the metrics you are measuring performance of test against. What type of data is it? 
- 0/1 -> Chi Square Test
- Normal/bootstrapped -> t-test
- Non-Normal -> Mann Whitney U test

When setting sig level at: 0.05, and stat test stat is < p-value then there is stat sig, reject H0 in favor or Ha. 

Concluding notes on experimentation:

• Make sure to control for endogeneity 
	1. Endogeneity- independent variable correlation with dependent variable unattributable because of unknown effect (used in: cause and effect in multivariate conditions); misattributing impact of experiment if not controlling for all variables 
		A. Disentangle causality in feature we were testing
• Sometimes learnings are not as expected from start of experiment.
Run tests multiple times if can afford it.
