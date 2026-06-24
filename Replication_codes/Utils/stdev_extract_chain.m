function stdev_ = stdev_extract_chain(oldcd,ind_endovar, folder_name, loadmat_name, savemat_name)

cd(folder_name)
load(loadmat_name, "oo_", "M_")
var_ = oo_.var;
    oo_a = oo_;
    M_a  = M_;
    save(savemat_name, "oo_a", "M_a")
cd(oldcd)
clear oo_ M_

stdev_ = sqrt(var_(ind_endovar,ind_endovar));


% cd model_network_emp/Output
%     load model_network_emp_results.mat oo_ M_
%     var_network_ = oo_.var;
%     if strcmp(case_i,'a')
%         oo_a = oo_;
%         M_a  = M_;
%         save("results_model_network_emp.mat", "oo_a", "M_a")
%     elseif strcmp(case_i,'b')
%         oo_b = oo_;
%         M_b  = M_;
%         save("results_model_network_emp.mat", "oo_b", "M_b", "-append")
%     elseif strcmp(case_i,'c')
%         oo_c = oo_;
%         M_c  = M_;
%         save("results_model_network_emp.mat", "oo_c", "M_c", "-append")
%     elseif strcmp(case_i,'d')
%         oo_d = oo_;
%         M_d  = M_;
%         save("results_model_network_emp.mat", "oo_d", "M_d", "-append")
%     end
% cd(oldcd)
% clear oo_ M_
% 
% cd model_network_comp/Output
%     load model_network_comp_results.mat oo_ M_
%     var_network_comp_ = oo_.var;
%     if strcmp(case_i,'a')
%         oo_a = oo_;
%         M_a  = M_;
%         save("results_model_network_comp.mat", "oo_a", "M_a")
%     elseif strcmp(case_i,'b')
%         oo_b = oo_;
%         M_b  = M_;
%         save("results_model_network_comp.mat", "oo_b", "M_b", "-append")
%     elseif strcmp(case_i,'c')
%         oo_c = oo_;
%         M_c  = M_;
%         save("results_model_network_comp.mat", "oo_c", "M_c", "-append")
%     elseif strcmp(case_i,'d')
%         oo_d = oo_;
%         M_d  = M_;
%         save("results_model_network_comp.mat", "oo_d", "M_d", "-append")
%     end
% cd(oldcd)
% clear oo_ M_
% 
% cd model_network_iso/Output
%     load model_network_iso_results.mat oo_ M_
%     var_network_iso_ = oo_.var;
%     if strcmp(case_i,'a')
%         oo_a = oo_;
%         M_a  = M_;
%         save("results_model_network_iso.mat", "oo_a", "M_a")
%     elseif strcmp(case_i,'b')
%         oo_b = oo_;
%         M_b  = M_;
%         save("results_model_network_iso.mat", "oo_b", "M_b", "-append")
%     elseif strcmp(case_i,'c')
%         oo_c = oo_;
%         M_c  = M_;
%         save("results_model_network_iso.mat", "oo_c", "M_c", "-append")
%     elseif strcmp(case_i,'d')
%         oo_d = oo_;
%         M_d  = M_;
%         save("results_model_network_iso.mat", "oo_d", "M_d", "-append")
%     end
% cd(oldcd)
% clear oo_ M_
% 
% cd model_network_star/Output
%     load model_network_star_results.mat oo_ M_
%     var_network_star_ = oo_.var;
%     if strcmp(case_i,'a')
%         oo_a = oo_;
%         M_a  = M_;
%         save("results_model_network_star.mat", "oo_a", "M_a")
%     elseif strcmp(case_i,'b')
%         oo_b = oo_;
%         M_b  = M_;
%         save("results_model_network_star.mat", "oo_b", "M_b", "-append")
%     elseif strcmp(case_i,'c')
%         oo_c = oo_;
%         M_c  = M_;
%         save("results_model_network_star.mat", "oo_c", "M_c", "-append")
%     elseif strcmp(case_i,'d')
%         oo_d = oo_;
%         M_d  = M_;
%         save("results_model_network_star.mat", "oo_d", "M_d", "-append")
%     end
% cd(oldcd)
% clear oo_ M_
% 
% if iL_ == 1
%     cd model_network_line/Output
%     load model_network_line_results.mat oo_ M_
%     var_network_line_ = oo_.var;
%     if strcmp(case_i,'a')
%         oo_a = oo_;
%         M_a  = M_;
%         save("results_model_network_line.mat", "oo_a", "M_a")
%     elseif strcmp(case_i,'b')
%         oo_b = oo_;
%         M_b  = M_;
%         save("results_model_network_line.mat", "oo_b", "M_b", "-append")
%     elseif strcmp(case_i,'c')
%         oo_c = oo_;
%         M_c  = M_;
%         save("results_model_network_line.mat", "oo_c", "M_c", "-append")
%     elseif strcmp(case_i,'d')
%         oo_d = oo_;
%         M_d  = M_;
%         save("results_model_network_line.mat", "oo_d", "M_d", "-append")
%     end
%     cd(oldcd)
%     clear oo_ M_
% end
% 
% 
% if iL_ == 1
%     stdev_pc_ = [
%         sqrt(var_network_(ind_endovar,ind_endovar));
%         sqrt(var_network_comp_(ind_endovar,ind_endovar));
%         sqrt(var_network_iso_(ind_endovar,ind_endovar));
%         sqrt(var_network_star_(ind_endovar,ind_endovar));
%         sqrt(var_network_line_(ind_endovar,ind_endovar));];
% else
%     stdev_pc_ = [
%         sqrt(var_network_(ind_endovar,ind_endovar));
%         sqrt(var_network_comp_(ind_endovar,ind_endovar));
%         sqrt(var_network_iso_(ind_endovar,ind_endovar));
%         sqrt(var_network_star_(ind_endovar,ind_endovar));];
% end
% 
% 
