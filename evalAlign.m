% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = 'data/eng_LM.mat';
fn_LMF       = 'data/fre_LM.mat';
fn_AM25      = 'data/eng_AM_25.mat';
fn_AM1000    = 'data/eng_AM_1000.mat';
fn_AM10000   = 'data/eng_AM_10000.mat';
fn_AM15000   = 'data/eng_AM_15000.mat';
fn_AM30000   = 'data/eng_AM_30000.mat';
lm_type      = '';
delta        = 1;
vocabSize    = 0;
numSentences = 25;
task5_dir_fre = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.f';
task5_dir_eng = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5.e';

% Train your language models and alignment models.
LME = lm_train(trainDir, 'e', 'eng_LM.mat');
LMF = lm_train(trainDir, 'f', 'fre_LM.mat');
eng_AM_25 = align_ibm1(trainDir, 25, 20, 'eng_AM_25.mat');
eng_AM_1000 = align_ibm1(trainDir, 1000, 20, 'eng_AM_1000.mat');
eng_AM_10000 = align_ibm1(trainDir, 10000, 20, 'eng_AM_10000.mat');
eng_AM_15000 = align_ibm1(trainDir, 15000, 20, 'eng_AM_15000.mat');
eng_AM_30000 = align_ibm1(trainDir, 30000, 20, 'eng_AM_30000.mat');

% LME = load(fn_LME);
% LME = LME.LM;
% LMF = load(fn_LMF);
% LMF = LMF.LM;
% eng_AM_1000 = load(fn_AM1000);
% eng_AM_1000 = eng_AM_1000.AM;
% eng_AM_10000 = load(fn_AM10000);
% eng_AM_10000 = eng_AM_10000.AM;
% eng_AM_15000 = load(fn_AM15000);
% eng_AM_15000 = eng_AM_15000.AM;
% eng_AM_30000 = load(fn_AM30000);
% eng_AM_30000 = eng_AM_30000.AM;

% Initialize values that will be used.
task5e = textread(task5_dir_eng, '%s', 'delimiter', '\n');
task5f = textread(task5_dir_fre, '%s', 'delimiter', '\n');
readSent = 0;
total_eng1k = 0;
total_eng10k = 0;
total_eng15k = 0;
total_eng30k = 0;
proper_align1k = 0;
proper_align10k = 0;
proper_align15k = 0;
proper_align30k = 0;

% For every english sentence we perform the following.
for i=1:length(task5f)
  readSent = readSent + 1;

  orig_eng_sent = strsplit(' ', preprocess(char(task5e(i)), 'e'))
  len_orig_eng = length(orig_eng_sent);
  
  % Use the decoder provided and translate the french with the models
  % above.
  eng_sent1k = decode(preprocess(char(task5f(i)), 'f'), LME, eng_AM_1000, '', delta, vocabSize)
  eng_sent10k = decode(preprocess(char(task5f(i)), 'f'), LME, eng_AM_10000, '', delta, vocabSize)
  eng_sent15k = decode(preprocess(char(task5f(i)), 'f'), LME, eng_AM_15000, '', delta, vocabSize)
  eng_sent30k = decode(preprocess(char(task5f(i)), 'f'), LME, eng_AM_30000, '', delta, vocabSize)

  % Determin minimum length of the two sentences.
  min_sent1k = min(length(eng_sent1k), len_orig_eng);
  min_sent10k = min(length(eng_sent10k), len_orig_eng);
  min_sent15k = min(length(eng_sent15k), len_orig_eng);
  min_sent30k = min(length(eng_sent30k), len_orig_eng);
  
  % Add those lengths to the respective total.
  total_eng1k = total_eng1k + min_sent1k;
  total_eng10k = total_eng10k + min_sent10k;
  total_eng15k = total_eng15k + min_sent15k;
  total_eng30k = total_eng30k + min_sent30k;

  % Determine and sum up the correctly translated and aligned words.
  for k=1:min_sent1k
      if strcmp(eng_sent1k{k}, orig_eng_sent{k})
          proper_align1k = proper_align1k + 1;
      end
  end
  for k=1:min_sent10k
      if strcmp(eng_sent10k{k}, orig_eng_sent{k})
          proper_align10k = proper_align10k + 1;
      end
  end
  for k=1:min_sent15k
      if strcmp(eng_sent15k{k}, orig_eng_sent{k})
          proper_align15k = proper_align15k + 1;
      end
  end
  for k=1:min_sent30k
      if strcmp(eng_sent30k{k}, orig_eng_sent{k})
          proper_align30k = proper_align30k + 1;
      end
  end

  % Quit after the specified number of sentences.
  if readSent == numSentences
      break
  end
end

% Display proportions.
proportion1k = proper_align1k / total_eng1k
proportion10k = proper_align10k / total_eng10k
proportion15k = proper_align15k / total_eng15k
proportion30k = proper_align30k / total_eng30k
