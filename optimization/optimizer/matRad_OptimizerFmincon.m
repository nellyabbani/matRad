classdef matRad_OptimizerFmincon < matRad_Optimizer
    %matRad_OptimizerFmincon Implements the interface for the fmincon
    %optimizer of the MATLAB Optiization toolbox
    
    properties
        options     %the optimoptions for fmincon
        wResult     %last optimization result
        resultInfo  %info struct about last results
    end
    
    methods
        function obj = matRad_OptimizerFmincon
            %matRad_OptimizerFmincon Construct an instance of this class
            
            obj.wResult = [];
            obj.resultInfo = [];
            
            %createDefaultOptimizerOptions Constructs a set of default
            %options for the optimizer to use
            obj.options = optimoptions('fmincon',...
                'Algorithm','interior-point',...
                'Display','iter-detailed',...
                'SpecifyObjectiveGradient',true,...
                'SpecifyConstraintGradient',true,...
                'AlwaysHonorConstraints', 'bounds',...
                'MaxIterations',500,...
                'MaxFunctionEvaluations',3000,...
                'CheckGradients',false,...
                'HessianApproximation',{'lbfgs',6},...
                'UseParallel',true,...
                'Diagnostics','on',...
                'ScaleProblem',true,...
                'PlotFcn',{@optimplotfval,@optimplotx,@optimplotfunccount,@optimplotconstrviolation,@optimplotstepsize,@optimplotfirstorderopt});                    
        end
                
        function obj = optimize(obj,w0,optiProb,dij,cst)
            %optimize Carries Out the optimization
            
            % obtain lower and upper variable bounds
            lb = optiProb.lowerBounds(w0);
            ub = optiProb.upperBounds(w0);
                        
            % Informing user to press q to terminate optimization
            %fprintf('\nOptimzation initiating...\n');
            %fprintf('Press q to terminate the optimization...\n');
            
            % Run fmincon.
            [obj.wResult,fVal,exitflag,info] = fmincon(@(x) obj.fmincon_objAndGradWrapper(x,optiProb,dij,cst),...
                w0,... % Starting Point
                [],[],... % Linear Constraints we do not explicitly use
                [],[],... % Also no linear inequality constraints
                lb,ub,... % Lower and upper bounds for optimization variable
                @(x) obj.fmincon_nonlconWrapper(x,optiProb,dij,cst),...
                obj.options); % Non linear constraint structure);
            
            obj.resultInfo = info;
            obj.resultInfo.fVal = fVal;
            obj.resultInfo.exitflag = exitflag;
        end
        
        function [f, fGrad] = fmincon_objAndGradWrapper(obj,x,optiProb,dij,cst)
            f = optiProb.matRad_objectiveFunction(x,dij,cst);
            fGrad = optiProb.matRad_objectiveGradient(x,dij,cst);
        end
        
        function [c,cEq,cJacob,cEqJacob] = fmincon_nonlconWrapper(obj,x,optiProb,dij,cst)
            %Get the bounds of the constraint
            [cl,cu] = optiProb.matRad_getConstraintBounds(cst);
            
            % Some checks
            assert(isequal(size(cl),size(cu)));
            assert(all(cl <= cu));
            
            %For fmincon we need to separate into equalty and inequality
            %constraints
            isEqConstr = (cl == cu);
            eqIx = find(isEqConstr);
            ineqIx = find(~isEqConstr);
            
            %Obtain all constraint functions and derivatives
            cVals = optiProb.matRad_constraintFunctions(x,dij,cst);
            cJacob = optiProb.matRad_constraintJacobian(x,dij,cst);
            
            %Subselection of equality constraints
            cEq = cVals(eqIx);
            cEqJacob = cJacob(eqIx,:)';
            
            %Prepare inequality constraints:
            %We need to separate upper and lower bound constraints for
            %fmincon
            cL = cl(ineqIx) - cVals(ineqIx);
            cU = cVals(ineqIx) - cu(ineqIx);
            cJacobL = -cJacob(ineqIx,:);
            cJacobU = cJacob(ineqIx,:);
            
            %build the inequality jacobian
            c = [cL; cU];
            cJacob = transpose([cJacobL; cJacobU]);
        end
        
        function [statusmsg,statusflag] = GetStatus(obj)
            try 
                statusmsg = obj.resultInfo.message;
                if obj.resultInfo.exitflag == 0
                    statusflag = 0;
                elseif obj.resultInfo.exitflag > 0
                    statusflag = 1;
                else 
                    statusflag = -1;
                end
            catch
                statusmsg = 'No Last Optimizer Status Available!';
                statusflag = -1;
            end
        end
    end
end