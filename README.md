# Decision-Support-System-for-Optimal-Player-Substitutions
Final project with Atharva Navaratne for the 15.095 Machine Learning under a Modern Optimization Lens class with Professor Kimberly Villalobos Carballo at MIT. Dec 9th, 2024.

In this project, we used prescriptive ML techniques (based on healthcare applications) to provide a framework professional football managers could use to aid in the substitution decision making process. First, K-means clustering was used to cluster substitutions into 4 different classes, depending only on data that describes the player being substituted in and the player being substituted out. Then, an Optimal Classification Tree (from IAI) was used to interpret the clusters based on an explanation that aligns well with an intuitive understanding of football substitutions.

Next, we consider each substitution as a "treatment" in the context of healthcare. Using the doubly robust counterfactual estimation method, we fit an Optimal Prescriptive Tree (from IAI) to prescribe specific substitution clusters depending on the current game situation. Finally, all available players on a team's roster are clustered, and their impact is predicted using a gradient boosting technique (XGBoost). Therefore, the framework can be summarized in the following 4 steps: 

1. Based on the game situation, choose which cluster of substitution is prescribed
2. Based on this cluster, determine which players on the bench and on the pitch are candidates for substitution
3. Choose the players from the above subset who will have the largest positive impact on the match if subbed in/out
4. Ensure that the substitution makes intuitive sense to the manager

Empirically, this framework is a way to optimize/perfect the strategy most coaches already use. For example, in the first match of Manchester United's 2024 season, the manager made two substitutions at the 61st minute that both aligned with the above framework. In fact, the winning goal was scored by one of the above offensive players who was substituted in. 

This repository includes an 8 page final paper outlining methodology and results, a short presentation, the code (written in python and Julia) used to clean the data, create the models and do the analysis, along with the data CSV files. If you have any questions or are interested in the process, data, models, code, or analysis, please do not hesitate to reach out!
