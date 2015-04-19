function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
% AM = align_ibm1('/h/u6/g0/00/g0quachb/Desktop/A2-401/testfiles/', 3, 20,
% '/h/u6/g0/00/g0quachb/Desktop/A2-401/testfiles/fn_AM')
  global CSC401_A2_DEFNS
  
  AM = struct();
  
  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);

  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end

% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

function [eng, fre] = read_hansard(dir_path, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
% 
%   dir_path = '/u/cs401/A2_SMT/data/Hansard/Training/';
%   numSentences = 100

  eng = {};
  fre = {};

  % TODO: your code goes here.
  readSent = 0;
  
  data_dir_eng = dir([dir_path, './*e']);
  length_of_DD = length(data_dir_eng);
  
  for k=1:length_of_DD
      
      if not(data_dir_eng(k).isdir)
          curr_file_eng = data_dir_eng(k).name;
          curr_file_fre = [curr_file_eng(1:length(curr_file_eng) - 1), 'f'];
          
          eng_data = textread([dir_path, curr_file_eng], '%s', 'delimiter', '\n');
          fre_data = textread([dir_path, curr_file_fre], '%s', 'delimiter', '\n');
          
          for i=1:length(eng_data)
              readSent = readSent + 1;
              eng{readSent} = strsplit(' ', preprocess(char(eng_data(i)), 'e'));
              fre{readSent} = strsplit(' ', preprocess(char(fre_data(i)), 'f'));
              if readSent == numSentences
                  return
              end
          end
      end
  end
end

function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = {}; % AM.(english_word).(foreign_word)

    % Initialize AM
    len = length(eng);
    
    for k=1:len
        eng_cell_sent = eng{k};
        fre_cell_sent = fre{k};
        len_eng = length(eng_cell_sent);
        len_fre = length(fre_cell_sent);
        for e=1:len_eng
            curr_eword = char(eng_cell_sent(e));
            if not(isfield(AM, curr_eword));
                AM.(curr_eword) = {};
            end
            for f=1:len_fre
                curr_fword = char(fre_cell_sent{f});
                if not(isfield(AM.(curr_eword), curr_fword))
                    AM.(curr_eword).(curr_fword) = 0;
                end
            end
        end
    end
    
    % Convert to vectors of possible french words to uniform probabilities.
    eng_fields = fieldnames(AM);
    eng_field_len = length(eng_fields);
    
    for a=1:eng_field_len
        curr_eng_field = eng_fields{a};
        
        fre_fields = fieldnames(AM.(curr_eng_field));
        fre_field_len = length(fre_fields);
        
        for b=1:fre_field_len
            curr_fre_field = fre_fields{b};
            AM.(curr_eng_field).(curr_fre_field) = 1 / fre_field_len;
        end
    end
    
    return
end

function AM = em_step(AM, eng, fre)
% 
% One step in the EM algorithm.
%
  tcount = AM;
  total = {};
  
  % set tcount(f, e) to 0 for all f, e
  eng_fields = fieldnames(tcount);
  eng_field_len = length(eng_fields);
    
  for a=1:eng_field_len
      curr_eng_field = eng_fields{a};
      
      % set total(e) to 0 for all e
      total.(curr_eng_field) = 0;
      
      fre_fields = fieldnames(tcount.(curr_eng_field));
      fre_field_len = length(fre_fields);

      for b=1:fre_field_len
          curr_fre_field = fre_fields{b};
          tcount.(curr_eng_field).(curr_fre_field) = 0;
      end
  end

  len_eng = length(eng);
  
  % a is sentence index.
  for a=1:len_eng
      
      unique_eng_sent = unique(eng{a});
      unique_fre_sent = unique(fre{a});
      len_uniq_eng = length(unique_eng_sent);
      len_uniq_fre = length(unique_fre_sent);
      
      for uf_ind=1:len_uniq_fre
          curr_fre_word = char(unique_fre_sent{uf_ind});
          denom_c = 0;
          countf = length(find(ismember(fre{a}, cellstr(curr_fre_word))));
          for ue_ind=1:len_uniq_eng
              curr_eng_word = char(unique_eng_sent{ue_ind});
              addon = AM.(curr_eng_word).(curr_fre_word) * countf;
              denom_c = denom_c + addon;
          end
          for ue_ind=1:len_uniq_eng
              curr_eng_word = char(unique_eng_sent{ue_ind});
              counte = length(find(ismember(eng{a}, cellstr(curr_eng_word))));
              addon = AM.(curr_eng_word).(curr_fre_word) * countf * counte / denom_c;
              tcount.(curr_eng_word).(curr_fre_word) = tcount.(curr_eng_word).(curr_fre_word) + addon;
              total.(curr_eng_word) = total.(curr_eng_word) + addon;
          end
      end
  end

  for e=1:eng_field_len
      curr_eng_word = char(eng_fields{e});
      fre_fields = fieldnames(tcount.(curr_eng_word));
      len_of_fre_fields = length(fre_fields);
      for f=1:len_of_fre_fields
          curr_fre_word = char(fre_fields{f});
          AM.(curr_eng_word).(curr_fre_word) = tcount.(curr_eng_word).(curr_fre_word) / total.(curr_eng_word);
      end
  end

  return
end


