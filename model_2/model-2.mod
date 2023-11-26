# Sets
param l;

set I;  # Set of electric plants
set T := 1..l;  # Planning horizon

# Parameters
param CA{I};  # Cost of startup for plant i
param CP{I};  # Cost of shutdown for plant i
param CF{I};  # Fixed operating cost for plant i
param CV{I};  # Variable operating cost for plant i
param Pmin{I};  # Minimum production for plant i
param Pmax{I};  # Maximum production for plant i
param U{I};  # Maximum increase allowed in production for plant i
param V{I};  # Minimum decrease allowed in production for plant i
param PI{I}; # Long term contract's price for the plant i
param D{T};  # Demand in period t
param r{T};  # Reserve factor in period t

# Variables
var Y{I, T} >= 0;  # Production of plant i in period t
var X{I, T} binary;  # Binary variable indicating if plant i is in operation in period t
var Z{I, T} binary;  # Binary variable indicating if plant i is started in period t


# Objective Function
maximize TotalBenefit:
	sum {i in I, t in T} (PI[i] * Y[i, t]) 
     - sum {i in I, t in T} (CA[i] * Z[i, t] + CP[i] * (1-Z[i, t]) + CF[i] * X[i, t] + CV[i] * Y[i, t]);

# Constraints
subject to ProductionLimits {i in I, t in T}:
    Pmin[i] <= Y[i, t] <= Pmax[i];

subject to ProductionChanges {i in I, t in T: t > 1}:
    -V[i] <= Y[i, t] - Y[i, t-1] <= U[i];

subject to DemandSatisfaction {t in T}:
    sum {i in I} Y[i, t] >= D[t];

subject to CorrectedReserveConstraint {t in T}:
    sum {i in I} Y[i, t] >= r[t];
    
subject to RelationBinaryVa {i in I, t in T}:
	Y[i, t] <= Pmax[i] * X[i, t];
    
subject to RelationBinaryVa2 {i in I, t in T}:
	Y[i, t] >= Pmax[i] * X[i, t];
	
subject to StartConstraints {i in I, t in T: t > 1}:
    Z[i, t] >= X[i, t] - X[i, t-1];

subject to StopConstraints {i in I, t in T: t > 1}:
    (1-Z[i, t]) >= X[i, t-1] - X[i, t];

subject to StartStopRelation {i in I, t in T}:
    Z[i, t] + (1-Z[i, t]) <= 1;
