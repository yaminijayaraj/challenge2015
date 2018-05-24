Simple ruby program to find the shortest degree of separation:

1. Program have the ability to search any level of degree of separation. But purely based on request lengths & time consumption.

2. Sample data used for first degree: [deepika-padukone,ranbir-kapoor],[vidya-balan,kareena-kapoor-khan]

3. Sample data used for third degree: [kangana-ranaut,divya-menon]

4. Overall Concept:

- Recursive forward trace used for finding the shortest degree. Parent of each request will be merged in each request.
- Recursive backward trace with respect to the parent element for finding the shortest degree. (Not completely done)
- Why forward & backward trace? In forward trace, huge amount of requests & calculations are already consuming more time. When we use both the strategy, we can simply backtrace with parent element merged with the data sent in recursion.
