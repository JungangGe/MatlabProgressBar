classdef ProgressBar_test < matlab.unittest.TestCase
    %PROGRESSBAR_TEST Unit test for ProgressBar.m
    % -------------------------------------------------------------------------
    % Run it by calling 'runtests()'
    %   or specifically 'runtests('ProgressBar_test')'
    %
    % Author :  J.-A. Adrian (JA) <jensalrik.adrian AT gmail.com>
    %
    
    
    properties (Constant)
        DEFAULT_SEED = 123;
    end
    
    properties
        UnitName = "ProgressBar";
        
        Seed;
    end
    
    
    methods (TestClassSetup)
        function setClassRng(testCase)
            testCase.Seed = rng();
            testCase.addTeardown(@rng, testCase.Seed);
            
            rng(testCase.DEFAULT_SEED);
        end
    end
    
    methods (TestMethodSetup)
        function setMethodRng(testCase)
            rng(testCase.DEFAULT_SEED);
        end
    end
    
    
    
    methods (Test)
        function testTimerDeletion(testCase)
            unit = testCase.getUnit();
            
            tagName = unit.TIMER_TAG_NAME;
            timer('Tag', tagName);
            testCase.verifyNotEmpty(timerfindall('Tag', tagName));
            
            unit.deleteAllTimers();
            testCase.verifyEmpty(timerfindall('Tag', tagName));
        end
        
        
        function testUnicodeBlocks(testCase)
            unit = testCase.getUnit();
            
            blocks = unit.getUnicodeSubBlocks();
            testCase.verifyEqual(blocks, '▏▎▍▌▋▊▉█');
        end
        
        
        function testAsciiBlocks(testCase)
            unit = testCase.getUnit();
            
            blocks = unit.getAsciiSubBlocks();
            testCase.verifyEqual(blocks, '########');
        end
        
        
        function testBackspaces(testCase)
            unit = testCase.getUnit();
            
            backspaces = unit.backspace(3);
            testCase.verifyEqual(backspaces, sprintf('\b\b\b'));
        end
        
        
        function testTimeConversion(testCase)
            unit = testCase.getUnit();
            
            testCase.verifyEqual(unit.convertTime(0), [0, 0, 0]);
            testCase.verifyEqual(unit.convertTime(30), [0, 0, 30]);
            testCase.verifyEqual(unit.convertTime(60), [0, 1, 0]);
            testCase.verifyEqual(unit.convertTime(60*60), [1, 0, 0]);
        end
        
        
        function checkBarLengthInput(testCase)
            unit = testCase.getUnit();
            
            testCase.verifyEqual(unit.checkInputOfTotal([]), true);
            testCase.verifyEqual(unit.checkInputOfTotal(10), false);
            
            testCase.verifyError(@() unit.checkInputOfTotal('char'), 'MATLAB:invalidType');
            testCase.verifyError(@() unit.checkInputOfTotal(-1), 'MATLAB:expectedPositive');
            testCase.verifyError(@() unit.checkInputOfTotal([1, 1]), 'MATLAB:expectedScalar');
            testCase.verifyError(@() unit.checkInputOfTotal(1j), 'MATLAB:expectedInteger');
            testCase.verifyError(@() unit.checkInputOfTotal(1.5), 'MATLAB:expectedInteger');
            testCase.verifyError(@() unit.checkInputOfTotal(inf), 'MATLAB:expectedInteger');
            testCase.verifyError(@() unit.checkInputOfTotal(nan), 'MATLAB:expectedInteger');
        end
        
        
        function findWorkerFiles(testCase)
            unit = testCase.getUnit();
            
            pattern = updateParallel();
            testCase.assertEmpty(dir(pattern));
            
            workerFilename = [pattern(1:end-1), 'test'];
            fid = fopen(workerFilename, 'w');
            fclose(fid);
            
            foundFiles = unit.findWorkerFiles(pwd());
            testCase.verifyEqual(length(foundFiles), 1);
            testCase.verifyEqual(foundFiles, {fullfile(pwd(), workerFilename)});
            
            delete(workerFilename);
        end
    end
    
    
    
    methods
        function [unit] = getUnit(testCase, len)
            if nargin < 2 || isempty(len)
                len = [];
            end
            
            unitHandle = str2func(testCase.UnitName);
            unit = unitHandle(len);
        end
    end
    
    
end
