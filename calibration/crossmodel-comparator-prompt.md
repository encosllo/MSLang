# Cross-model calibration comparator prompt (Section 11.4)

You are a blind comparator. Below are 23 pairs, each a CONTRACT (an informal
mathematical claim) and a READBACK (an informal rendering of a formal statement).
For each pair decide the correspondence verdict:

- `equivalent` — same statement;
- `formal_stronger` — the readback assumes less / concludes more than the contract;
- `formal_weaker` — the readback assumes more / concludes less than the contract;
- `incomparable` — neither implies the other;
- `ill_posed` — the readback cannot be made precise, or is not a well-formed claim.

Judge each pair on its own. Do not use outside knowledge, do not consult any
repository, and do not infer an expected answer.

Report your model identifier and family first (family = first hyphen-segment of the id).
Then output exactly one line per case, in the form `<ID>: <verdict>`, using only the
five verdicts above.

---

## CAL-001

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). If Phi is contained in Psi, then Psi-Sat(A) is contained in Phi-Sat(A). (Eqv(A) = S-sorted equivalences on A; Phi contained in Psi = relation inclusion; Theta-Sat(A) = the componentwise subsets X of A with X = [X]^Theta; X is Theta-saturated iff X = [X]^Theta.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Suppose Phi refines Psi (every pair related by Phi is related by Psi). Then every componentwise subset X of A that is Psi-saturated (X = [X]^Psi) is also Phi-saturated (X = [X]^Phi).

## CAL-002

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). If Phi is contained in Psi, then Psi-Sat(A) is contained in Phi-Sat(A).

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Suppose Psi refines Phi (every pair related by Psi is related by Phi). Then every componentwise subset X of A that is Psi-saturated is also Phi-saturated.

## CAL-003

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). If Phi is contained in Psi, then Psi-Sat(A) is contained in Phi-Sat(A).

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Suppose Phi refines Psi. Then every componentwise subset X of A that is Phi-saturated is also Psi-saturated.

## CAL-004

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi is contained in Psi if and only if, for every componentwise subset X of A, [[X]^Psi]^Phi = [X]^Psi. (Saturate X by Psi first, then by Phi.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Then Phi refines Psi if and only if, for every componentwise subset X of A, saturating X by Psi and then by Phi equals saturating X by Psi alone.

## CAL-005

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi is contained in Psi if and only if, for every componentwise subset X of A, [[X]^Psi]^Phi = [X]^Psi. (Saturate X by Psi first, then by Phi.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Then Phi refines Psi if and only if, for every componentwise subset X of A, saturating X by Phi and then by Psi equals saturating X by Phi alone.

## CAL-006

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi is contained in Psi if and only if, for every componentwise subset X of A, [[X]^Psi]^Phi = [X]^Psi.

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Then Phi refines Psi if and only if there exists a componentwise subset X of A such that saturating X by Psi and then by Phi equals saturating X by Psi alone.

## CAL-007

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi-Sat(A) intersect Psi-Sat(A) is contained in (Phi intersect Psi)-Sat(A). (Phi intersect Psi is the pointwise intersection of the relations.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. If a componentwise subset X of A is Phi-saturated, then X is saturated under the pointwise intersection Phi intersect Psi.

## CAL-008

CONTRACT: Let A be an S-sorted set and X a componentwise subset of A. Then X is nabla-saturated if and only if, for every sort s, if s is in the support of X (X_s nonempty) then X_s = A_s.

READBACK: Fix an S-sorted set A and a componentwise subset X of A. Then X is saturated under the universal relation nabla if and only if, for every sort s, if the component X_s is nonempty then X_s is nonempty.

## CAL-009

CONTRACT: Let A be an S-sorted set and X a componentwise subset of A. Then X is nabla-saturated if and only if, for every sort s, if s is in the support of X (X_s nonempty) then X_s = A_s.

READBACK: Fix an S-sorted set A and a componentwise subset X of A. Then X is saturated under the universal relation nabla if and only if, for every sort s, if the component X_s is nonempty then X_s equals all of A_s.

## CAL-010

CONTRACT: Let A be an S-sorted set and X a componentwise subset of A. Then X is nabla-saturated if and only if, for every sort s, if s is in the support of X (X_s nonempty) then X_s = A_s.

READBACK: Fix an S-sorted set A and a componentwise subset X of A. Then X is saturated under the universal relation nabla if and only if, for every sort s, X_s equals all of A_s.

## CAL-011

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi-Sat(A) intersect Psi-Sat(A) is contained in (Phi intersect Psi)-Sat(A). (Phi intersect Psi is the pointwise intersection of the relations.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. If a componentwise subset X of A is saturated under both Phi and Psi, then X is saturated under the pointwise intersection Phi intersect Psi.

## CAL-G001

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). If Phi is contained in Psi, then Psi-Sat(A) is contained in Phi-Sat(A). (Eqv(A) = S-sorted equivalences on A; Phi contained in Psi = relation inclusion; Theta-Sat(A) = the componentwise subsets X of A with X = [X]^Theta; X is Theta-saturated iff X = [X]^Theta.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Suppose Phi refines Psi (every pair related by Phi is related by Psi). Then every componentwise subset X of A that is Psi-saturated (X = [X]^Psi) is also Psi-saturated (X = [X]^Phi).

## CAL-G002

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). If Phi is contained in Psi, then Psi-Sat(A) is contained in Phi-Sat(A). (Eqv(A) = S-sorted equivalences on A; Phi contained in Psi = relation inclusion; Theta-Sat(A) = the componentwise subsets X of A with X = [X]^Theta; X is Theta-saturated iff X = [X]^Theta.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Suppose Psi refines Phi (every pair related by Psi is related by Phi). Then every componentwise subset X of A that is Psi-saturated (X = [X]^Psi) is also Phi-saturated (X = [X]^Phi).

## CAL-G003

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). If Phi is contained in Psi, then Psi-Sat(A) is contained in Phi-Sat(A). (Eqv(A) = S-sorted equivalences on A; Phi contained in Psi = relation inclusion; Theta-Sat(A) = the componentwise subsets X of A with X = [X]^Theta; X is Theta-saturated iff X = [X]^Theta.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Then every componentwise subset X of A that is Psi-saturated (X = [X]^Psi) is also Phi-saturated (X = [X]^Phi).

## CAL-G004

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). If Phi is contained in Psi, then Psi-Sat(A) is contained in Phi-Sat(A). (Eqv(A) = S-sorted equivalences on A; Phi contained in Psi = relation inclusion; Theta-Sat(A) = the componentwise subsets X of A with X = [X]^Theta; X is Theta-saturated iff X = [X]^Theta.)

READBACK: Fix an S-sorted set A and S-sorted relations Phi, Psi on A. Suppose Phi refines Psi (every pair related by Phi is related by Psi). Then every componentwise subset X of A that is Psi-saturated (X = [X]^Psi) is also Phi-saturated (X = [X]^Phi).

## CAL-G005

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi-Sat(A) intersect Psi-Sat(A) is contained in (Phi intersect Psi)-Sat(A). (Phi intersect Psi is the pointwise intersection of the relations.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. If a componentwise subset X of A is saturated under Phi, then X is saturated under the pointwise intersection Phi intersect Psi.

## CAL-G006

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi-Sat(A) intersect Psi-Sat(A) is contained in (Phi intersect Psi)-Sat(A). (Phi intersect Psi is the pointwise intersection of the relations.)

READBACK: Fix an S-sorted set A and S-sorted relations Phi, Psi on A. If a componentwise subset X of A is saturated under both Phi and Psi, then X is saturated under the pointwise intersection Phi intersect Psi.

## CAL-G007

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi is contained in Psi if and only if, for every componentwise subset X of A, [[X]^Psi]^Phi = [X]^Psi. (Saturate X by Psi first, then by Phi.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Then Psi refines Phi if and only if, for every componentwise subset X of A, saturating X by Psi and then by Phi equals saturating X by Psi alone.

## CAL-G008

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi is contained in Psi if and only if, for every componentwise subset X of A, [[X]^Psi]^Phi = [X]^Psi. (Saturate X by Psi first, then by Phi.)

READBACK: Fix an S-sorted set A and S-sorted relations Phi, Psi on A. Then Phi refines Psi if and only if, for every componentwise subset X of A, saturating X by Psi and then by Phi equals saturating X by Psi alone.

## CAL-G009

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi is contained in Psi if and only if, for every componentwise subset X of A, [[X]^Psi]^Phi = [X]^Psi. (Saturate X by Psi first, then by Phi.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Then Phi refines Psi if and only if, there exists a componentwise subset X of A, saturating X by Psi and then by Phi equals saturating X by Psi alone.

## CAL-G010

CONTRACT: Let A be an S-sorted set and Phi, Psi in Eqv(A). Then Phi is contained in Psi if and only if, for every componentwise subset X of A, [[X]^Psi]^Phi = [X]^Psi. (Saturate X by Psi first, then by Phi.)

READBACK: Fix an S-sorted set A and S-sorted equivalences Phi, Psi on A. Then Phi refines Psi if and only if, for every componentwise subset X of A, saturating X by Phi and then by Psi equals saturating X by Phi alone.

## CAL-G011

CONTRACT: Let A be an S-sorted set and X a componentwise subset of A. Then X is nabla-saturated if and only if, for every sort s, if s is in the support of X (X_s nonempty) then X_s = A_s.

READBACK: Fix an S-sorted set A and a componentwise subset X of A. Then X is saturated under the universal relation nabla if and only if, there exists a sort s, if the component X_s is nonempty then X_s equals all of A_s.

## CAL-G012

CONTRACT: Let A be an S-sorted set and X a componentwise subset of A. Then X is nabla-saturated if and only if, for every sort s, if s is in the support of X (X_s nonempty) then X_s = A_s.

READBACK: Fix an S-sorted set A and a componentwise subset X of A. Then X is saturated under the universal relation nabla if and only if, for every sort s, if the component X_s is nonempty then X_s is nonempty.
