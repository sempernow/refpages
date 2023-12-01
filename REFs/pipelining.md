# Pipelining

AKA The Industrial Revolution  
(fathered by Henry Ford).

Here's a pipeline voyage from laundry to heaven:

## Example : Laundry

Laundry takes, say, 60 minutes per load.

What happens when we decompose 
the laundry task into its constituent tasks,
and exploit that with pipeline processing:

    T1  T2  Δt  L    T      NT     D
    --  --  --  -   ----   -----  ---
     1   0   0  0     0
     2   1  20  0    20
     3   2  40  1    60      60     0
     4   3  40  2   100     120    20
     5   4  40  3   140     180    40
     6   5  40  4   180     240    60

- T1 : Washer task iteration, which takes 20 minutes/task
- T2 : Dryer task iteration, which takes 40 minutes/task
- Δt : Time per final result (iteration)
- L  : Number of loads (final results) completed
- T  : Total time since pipeline start
- NT : L * 60 : Total time if no pipeline : L * (T1.time + T2.time)
- D  : NT - T : Total-time difference : Sans pipelining v. pipelining

## Findings:

- Before the pipeline fills, it has no benefit.
  That is, T grows identically to that of no pipeline,
  which is the sum of all completed tasks.
- Once the pipeline fills,
  T grows by increments of only the longest task (T2).
  That is, a final __result is delivered per longest-task__,
  rather than per sum-of-all-tasks.
- Pipeline __benefit scales linearly__, and __in both dimensions__:
    - Number of tasks
    - Number of iterations (final results)

This also reveals why information technology (IT)
is not Computer Science.
It isn't about computers,
and it's not a science.
It's rather about the technologies born of humans
harvesting the (super)natural properties of information.

The entirety of the physical world is fully definable.
That is, this "real" world is mappable to information.
However, the inverse is not true.
Information is not bound by the physical (natural) world.
Mathematics, for example.
This implies the natural world is only a subset of information.
Hence, information is definitively supernatural.

--- 

Space and time (R4) and all matter and energy therein,
otherwise referred to in modernity as "reality",
is merely a kind of shadow (subset) cast by
a higher-dimensional reality
(some call that heaven),
which suggests if not implies
a supernatural totality of all realities
(some call that God).

---

<!--

# Markdown Cheatsheet

[Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet "Wiki @ GitHub")

# Bookmark

- Reference
[Foo](#foo)

- Target
<a name="foo"></a>

-->
