// See https://aka.ms/new-console-template for more information
using System.Diagnostics;
Stopwatch sw = new Stopwatch();
sw.Start();
Console.WriteLine("Starting...");
long rolls = 1000000000;
var executionResult = executeRolls(rolls);
Console.WriteLine("Highest Ones Roll: {0}", executionResult);
Console.WriteLine("finished in {0} seconds", sw.Elapsed.TotalSeconds);
Console.ReadLine();

int executeRolls(long amount)
{
    var randomNumberGenerator = new Random();
    int[] numbers = { 0, 0, 0, 0 }; // numbers = [0,0,0,0]
    long rolls = 0;
    int maxOnes = 0;
    while (numbers[0] < 177 && rolls < amount)//while numbers[0] < 177 and rolls< 1000000000:
    {
        numbers = new int[] { 0, 0, 0, 0 }; // numbers = [0, 0, 0, 0]
        for (int i = 0; i < 231; i++) // for i in repeat(None, 231):
        {
            var roll = randomNumberGenerator.Next(1, 4); //roll = random.choice(items)
            numbers[roll - 1] = numbers[roll - 1] + 1; // numbers[roll - 1] = numbers[roll - 1] + 1
        }
        rolls = rolls + 1; // rolls = rolls + 1
        if (numbers[0] > maxOnes) // if numbers[0] > maxOnes:
            maxOnes = numbers[0]; // maxOnes = numbers[0]
    }
    return maxOnes;
}