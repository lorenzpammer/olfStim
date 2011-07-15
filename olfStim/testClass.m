classdef testClass
    %TESTCLASS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        a
        b
        c
    end
    
    methods
        
        function obj = testClass
            obj.a = 1;
            obj.b = 2;
            testClass.testClass2
            
        end
        function obj = testClass2
            obj.c = 3;
        end
    end
    
end

