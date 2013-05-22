require Logic.
module M1 = {
  var y : int
  var z : int
  fun f (x:int) : int = { 
    y = x;
    return 3;
  }

  fun g (x:int) : int = {
    var r : int;
    r := f(x);
    return r;
  }
}.

module M2 = {
  var y : int
  var z : int
  fun f (w:int) : int = { 
    y = w;
    return 3;
  }

  fun g (w:int) : int = {
    var r : int;
    r := f(w);
    return r;
  }
}.


lemma foo : 
  equiv [M1.g ~ M2.g : M1.z{1}=M2.z{2} /\ M1.y{1} = M2.y{2} /\ x{1} = w{2} 
        ==> res{1} = res{2} /\ M1.z{1} = M2.z{2} /\ M1.y{1} = M2.y{2}]
proof.
  fun.
  call (x{1}=w{2}) (res{1} = res{2} /\ M1.y{1} = M2.y{2}).
    fun;wp;skip.
    intros &m1 &m2 h;simplify;assumption.
  skip.
  intros &m1 &m2 h;elim h;clear h;intros h1 h2.
  elim h2;clear h2;intros h2 h3.
<<<<<<< HEAD
  rewrite h1; rewrite h3;simplify.
  intros _ _ _ _;split.
=======
  split;[ assumption | intros _ rL rR y1 y2 h];elim h;clear h;intros _ _.
  subst;simplify;assumption.
>>>>>>> 1e740813982cfd92884406e8dabdae70bd47e4f3
save.
