(*<*)
theory Proof_System
  imports MFOTL
begin
(*>*)

section \<open>Proof System\<close>

subsection \<open>Time-stamp-time-point Conversion\<close>

definition ETP:: "'a trace \<Rightarrow> nat \<Rightarrow> nat"  where
    "ETP \<sigma> ts = (LEAST i. \<tau> \<sigma> i \<ge> ts)"

definition LTP:: "'a trace \<Rightarrow> nat \<Rightarrow> nat" where
    "LTP \<sigma> ts = Max {i. (\<tau> \<sigma> i) \<le> ts}"

abbreviation "\<delta> \<sigma> i j \<equiv> (\<tau> \<sigma> i - \<tau> \<sigma> j)"

abbreviation "ETP_p \<sigma> i b \<equiv> ETP \<sigma> ((\<tau> \<sigma> i) - b)"
abbreviation "LTP_p \<sigma> i I \<equiv> min i (LTP \<sigma> ((\<tau> \<sigma> i) - left I))"
abbreviation "ETP_f \<sigma> i I \<equiv> max i (ETP \<sigma> ((\<tau> \<sigma> i) + left I))"
abbreviation "LTP_f \<sigma> i b \<equiv> LTP \<sigma> ((\<tau> \<sigma> i) + b)"

subsection \<open>Soundness and Completeness\<close>

inductive SAT and VIO :: "'a MFOTL.trace \<Rightarrow> 'a MFOTL.env \<Rightarrow> nat \<Rightarrow> 'a MFOTL.formula \<Rightarrow> bool" where
  STT: "SAT \<sigma> v i TT"
| VFF: "VIO \<sigma> v i FF"
| SPred: "(r, MFOTL.eval_trms v ts) \<in> \<Gamma> \<sigma> i \<Longrightarrow> SAT \<sigma> v i (MFOTL.Pred r ts)"
| VPred: "(r, MFOTL.eval_trms v ts) \<notin> \<Gamma> \<sigma> i \<Longrightarrow> VIO \<sigma> v i (MFOTL.Pred r ts)"
| SEq: "(MFOTL.eval_trm v t1) = (MFOTL.eval_trm v t2) \<Longrightarrow> SAT \<sigma> v i (MFOTL.Eq t1 t2)"
| VEq: "(MFOTL.eval_trm v t1) \<noteq> (MFOTL.eval_trm v t2) \<Longrightarrow> VIO \<sigma> v i (MFOTL.Eq t1 t2)"
| SNeg: "VIO \<sigma> v i \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Neg \<phi>)"
| VNeg: "SAT \<sigma> v i \<phi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Neg \<phi>)"
| SOrL: "SAT \<sigma> v i \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Or \<phi> \<psi>)"
| SOrR: "SAT \<sigma> v i \<psi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Or \<phi> \<psi>)"
| VOr: "VIO \<sigma> v i \<phi> \<Longrightarrow> VIO \<sigma> v i \<psi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Or \<phi> \<psi>)"
| SAnd: "SAT \<sigma> v i \<phi> \<Longrightarrow> SAT \<sigma> v i \<psi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.And \<phi> \<psi>)"
| VAndL: "VIO \<sigma> v i \<phi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.And \<phi> \<psi>)"
| VAndR: "VIO \<sigma> v i \<psi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.And \<phi> \<psi>)"
| SImplL: "VIO \<sigma> v i \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Imp \<phi> \<psi>)"
| SImplR: "SAT \<sigma> v i \<psi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Imp \<phi> \<psi>)"
| VImpl: "SAT \<sigma> v i \<phi> \<Longrightarrow> VIO \<sigma> v i \<psi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Imp \<phi> \<psi>)"
| SIffSS: "SAT \<sigma> v i \<phi> \<Longrightarrow> SAT \<sigma> v i \<psi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Iff \<phi> \<psi>)"
| SIffVV: "VIO \<sigma> v i \<phi> \<Longrightarrow> VIO \<sigma> v i \<psi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Iff \<phi> \<psi>)"
| VIffSV: "SAT \<sigma> v i \<phi> \<Longrightarrow> VIO \<sigma> v i \<psi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Iff \<phi> \<psi>)"
| VIffVS: "VIO \<sigma> v i \<phi> \<Longrightarrow> SAT \<sigma> v i \<psi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Iff \<phi> \<psi>)"
| SExists: "\<exists>z. SAT \<sigma> (v (x := z)) i \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Exists x \<phi>)"
| VExists: "\<forall>z. VIO \<sigma> (v (x := z)) i \<phi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Exists x \<phi>)"
| SForall: "\<forall>z. SAT \<sigma> (v (x := z)) i \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Forall x \<phi>)"
| VForall: "\<exists>z. VIO \<sigma> (v (x := z)) i \<phi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Forall x \<phi>)"
| SPrev: "i > 0 \<Longrightarrow> mem (\<Delta> \<sigma> i) I \<Longrightarrow> SAT \<sigma> v (i-1) \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Prev I \<phi>)"
| VPrev: "i > 0 \<Longrightarrow> VIO \<sigma> v (i-1) \<phi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Prev I \<phi>)"
| VPrevZ: "i = 0 \<Longrightarrow> VIO \<sigma> v i (MFOTL.Prev I \<phi>)"
| VPrevOutL: "i > 0 \<Longrightarrow> (\<Delta> \<sigma> i) < (left I) \<Longrightarrow> VIO \<sigma> v i (MFOTL.Prev I \<phi>)"
| VPrevOutR: "i > 0 \<Longrightarrow> enat (\<Delta> \<sigma> i) > (right I) \<Longrightarrow> VIO \<sigma> v i (MFOTL.Prev I \<phi>)"
| SNext: "mem (\<Delta> \<sigma> (i+1)) I \<Longrightarrow> SAT \<sigma> v (i+1) \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Next I \<phi>)"
| VNext: "VIO \<sigma> v (i+1) \<phi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Next I \<phi>)"
| VNextOutL: "(\<Delta> \<sigma> (i+1)) < (left I) \<Longrightarrow> VIO \<sigma> v i (MFOTL.Next I \<phi>)"
| VNextOutR: "enat (\<Delta> \<sigma> (i+1)) > (right I) \<Longrightarrow> VIO \<sigma> v i (MFOTL.Next I \<phi>)"
| SOnce: "j \<le> i \<Longrightarrow> mem (\<delta> \<sigma> i j) I \<Longrightarrow> SAT \<sigma> v j \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Once I \<phi>)"
| VOnceOut: "\<tau> \<sigma> i < \<tau> \<sigma> 0 + left I \<Longrightarrow> VIO \<sigma> v i (MFOTL.Once I \<phi>)"
| VOnce: "j = (case right I of \<infinity> \<Rightarrow> 0 
               | enat b \<Rightarrow> ETP_p \<sigma> i b) \<Longrightarrow>
          (\<tau> \<sigma> i) \<ge> (\<tau> \<sigma> 0) + left I \<Longrightarrow>
          (\<And>k. k \<in> {j .. LTP_p \<sigma> i I} \<Longrightarrow> VIO \<sigma> v k \<phi>) \<Longrightarrow> VIO \<sigma> v i (MFOTL.Once I \<phi>)"
| SEventually: "j \<ge> i \<Longrightarrow> mem (\<delta> \<sigma> j i) I  \<Longrightarrow> SAT \<sigma> v j \<phi> \<Longrightarrow> SAT \<sigma> v i (MFOTL.Eventually I \<phi>)"
| VEventually: "(\<And>k. k \<in> (case right I of \<infinity> \<Rightarrow> {ETP_f \<sigma> i I ..}
                           | enat b \<Rightarrow> {ETP_f \<sigma> i I .. LTP_f \<sigma> i b}) \<Longrightarrow> VIO \<sigma> v k \<phi>) \<Longrightarrow> 
                VIO \<sigma> v i (MFOTL.Eventually I \<phi>)"
| SHistorically: "j = (case right I of \<infinity> \<Rightarrow> 0
               | enat b \<Rightarrow> ETP_p \<sigma> i b) \<Longrightarrow>
          (\<tau> \<sigma> i) \<ge> (\<tau> \<sigma> 0) + left I \<Longrightarrow>
          (\<And>k. k \<in> {j .. LTP_p \<sigma> i I} \<Longrightarrow> SAT \<sigma> v k \<phi>) \<Longrightarrow> SAT \<sigma> v i (MFOTL.Historically I \<phi>)"
| SHistoricallyOut: "\<tau> \<sigma> i < \<tau> \<sigma> 0 + left I \<Longrightarrow> SAT \<sigma> v i (MFOTL.Historically I \<phi>)"
| VHistorically: "j \<le> i \<Longrightarrow> mem (\<delta> \<sigma> i j) I  \<Longrightarrow> VIO \<sigma> v j \<phi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Historically I \<phi>)"
| SAlways: "(\<And>k. k \<in> (case right I of \<infinity> \<Rightarrow> {lu i I ..} 
                       | enat b \<Rightarrow> {ETP_f \<sigma> i I .. LTP_f \<sigma> i b}) \<Longrightarrow> SAT \<sigma> v k \<phi>) \<Longrightarrow>
            SAT \<sigma> v i (MFOTL.Always I \<phi>)"
| VAlways: "j \<ge> i \<Longrightarrow> mem (\<delta> \<sigma> j i) I  \<Longrightarrow> VIO \<sigma> v j \<phi> \<Longrightarrow> VIO \<sigma> v i (MFOTL.Always I \<phi>)"
| SSince: "j \<le> i \<Longrightarrow> mem (\<delta> \<sigma> i j) I  \<Longrightarrow> SAT \<sigma> v j \<psi> \<Longrightarrow> (\<And>k. k \<in> {j <.. i} \<Longrightarrow> 
           SAT \<sigma> v k \<phi>) \<Longrightarrow> SAT \<sigma> v i (MFOTL.Since \<phi> I \<psi>)"
| VSinceOut: "\<tau> \<sigma> i < \<tau> \<sigma> 0 + left I \<Longrightarrow> VIO \<sigma> v i (MFOTL.Since \<phi> I \<psi>)"
| VSince: "(case right I of \<infinity> \<Rightarrow> True 
            | enat b \<Rightarrow> ETP \<sigma> ((\<tau> \<sigma> i) - b) \<le> j) \<Longrightarrow> 
           j \<le> i \<Longrightarrow> (\<tau> \<sigma> 0) + left I \<le> (\<tau> \<sigma> i) \<Longrightarrow> VIO \<sigma> v j \<phi> \<Longrightarrow>
           (\<And>k. k \<in> {j .. (LTP_p \<sigma> i I)} \<Longrightarrow> VIO \<sigma> v k \<psi>) \<Longrightarrow> VIO \<sigma> v i (MFOTL.Since \<phi> I \<psi>)"
| VSinceInf: "j = (case right I of \<infinity> \<Rightarrow> 0 
                      | enat b \<Rightarrow> ETP_p \<sigma> i b) \<Longrightarrow>
                 (\<tau> \<sigma> i) \<ge> (\<tau> \<sigma> 0) + left I \<Longrightarrow> 
                 (\<And>k. k \<in> {j .. LTP_p \<sigma> i I} \<Longrightarrow> VIO \<sigma> v k \<psi>) \<Longrightarrow> VIO \<sigma> v i (MFOTL.Since \<phi> I \<psi>)"
| SUntil: "j \<ge> i \<Longrightarrow> mem (\<delta> \<sigma> j i) I  \<Longrightarrow> SAT \<sigma> v j \<psi> \<Longrightarrow> (\<And>k. k \<in> {i ..< j} \<Longrightarrow> SAT \<sigma> v k \<phi>) \<Longrightarrow> 
           SAT \<sigma> v i (MFOTL.Until \<phi> I \<psi>)"
| VUntil: "(case right I of \<infinity> \<Rightarrow> True 
            | enat b \<Rightarrow> j \<le> LTP_f \<sigma> i b) \<Longrightarrow> 
           j \<ge> i \<Longrightarrow> VIO \<sigma> v j \<phi> \<Longrightarrow> (\<And>k. k \<in> {ETP_f \<sigma> i I .. j} \<Longrightarrow> VIO \<sigma> v k \<psi>) \<Longrightarrow> 
           VIO \<sigma> v i (MFOTL.Until \<phi> I \<psi>)"
| VUntilInf: "(\<And>k. k \<in> (case right I of \<infinity> \<Rightarrow> {ETP_f \<sigma> i I ..} 
                            | enat b \<Rightarrow> {ETP_f \<sigma> i I .. LTP_f \<sigma> i b}) \<Longrightarrow> VIO \<sigma> v k \<psi>) \<Longrightarrow>
              VIO \<sigma> v i (MFOTL.Until \<phi> I \<psi>)"

lemma soundness: "(SAT \<sigma> v i \<phi> \<longrightarrow> MFOTL.sat \<sigma> v i \<phi>) \<and> (VIO \<sigma> v i \<phi> \<longrightarrow> \<not> MFOTL.sat \<sigma> v i \<phi>)"
  oops

lemma completeness: "(MFOTL.sat \<sigma> v i \<phi> \<longrightarrow> SAT \<sigma> v i \<phi>) \<and> (\<not> MFOTL.sat \<sigma> v i \<phi> \<longrightarrow> VIO \<sigma> v i \<phi>)"
proof (induct \<phi> arbitrary: i)
  case (Prev x1 \<phi>)
  then show ?case sorry
next
  case (Next x1 \<phi>)
  then show ?case sorry
next
  case (Once x1 \<phi>)
  then show ?case sorry
next
  case (Historically x1 \<phi>)
  then show ?case sorry
next
  case (Eventually x1 \<phi>)
  then show ?case sorry
next
  case (Always x1 \<phi>)
  then show ?case sorry
next
  case (Since \<phi>1 x2 \<phi>2)
  then show ?case sorry
next
  case (Until \<phi>1 x2 \<phi>2)
  then show ?case sorry
qed (auto intro: SAT_VIO.intros)


typedef ('d, 'v) partition = "{xs :: ('d set \<times> 'v) list. (\<Union>X \<in> fst ` set xs. X) = UNIV
  \<and> (\<forall>i < length xs. \<forall>j < length xs. i \<noteq> j \<longrightarrow> fst (xs ! i) \<inter> fst (xs ! j) = {})}"
  by (rule exI[of _ "[(UNIV, undefined)]"]) auto

lift_bnf (no_warn_wits, no_warn_transfer) (dead 'd, 'v) partition
  by auto

datatype (dead 'd) sproof = STT nat 
  | SPred nat MFOTL.name "'d MFOTL.trm list" 
  | SEq nat "'d MFOTL.trm" "'d MFOTL.trm"
  | SNeg "'d vproof" 
  | SOrL "'d sproof" 
  | SOrR "'d sproof" 
  | SAnd "'d sproof" "'d sproof"
  | SImplL "'d vproof" 
  | SImplR "'d sproof"
  | SIffSS "'d sproof" "'d sproof" 
  | SIffVV "'d vproof" "'d vproof" 
  | SExists "'d sproof"
  | SForall "('d, 'd sproof) partition" 
  | SPrev "'d sproof"
  | SNext "'d sproof"
  | SOnce nat "'d sproof"
  | SEventually nat "'d sproof" 
  | SHistorically nat nat "'d sproof list" 
  | SHistoricallyOut nat
  | SAlways nat nat "'d sproof list"
  | SSince "'d sproof" "'d sproof list" 
  | SUntil "'d sproof list" "'d sproof" 
  and 'd vproof = VFF nat 
  | VPred nat MFOTL.name "'d MFOTL.trm list" 
  | VEq nat "'d MFOTL.trm" "'d MFOTL.trm"
  | VNeg "'d sproof" 
  | VOr "'d sproof" "'d sproof"
  | VAndL "'d vproof" 
  | VAndR "'d vproof" 
  | VImpl "'d sproof" "'d vproof" 
  | VIffSV "'d sproof" "'d vproof" 
  | VIffVS "'d vproof" "'d sproof" 
  | VExists "('d, 'd vproof) partition" 
  | VForall "'d vproof"
  | VPrev "'d vproof"
  | VPrevZ
  | VPrevOutL nat 
  | VPrevOutR nat
  | VNext "'d vproof" 
  | VNextOutL nat 
  | VNextOutR nat 
  | VOnceOut nat 
  | VOnce nat nat "'d vproof list" 
  | VEventually nat nat "'d vproof list"
  | VHistorically nat "'d vproof" 
  | VAlways nat "'d vproof"
  | VSinceOut nat
  | VSince nat "'d vproof" "'d vproof list" 
  | VSinceInf nat nat "'d vproof list" 
  | VUntil nat "'d vproof list" "'d vproof"
  | VUntilInf nat nat "'d vproof list" 

(* Partitioned Decision Tree *)
datatype ('v, 'd, 'e) pdt = Leaf 'e | Node 'v "('d, ('v, 'd, 'e) pdt) partition"

type_synonym ('v, 'd) expl = "('v, 'd, 'd sproof + 'd vproof) pdt"

end