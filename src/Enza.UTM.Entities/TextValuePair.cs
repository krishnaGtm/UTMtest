namespace Enza.UTM.Entities
{
    public class TextValuePair<TText, TValue>
    {
        public TextValuePair()
        {

        }
        public TextValuePair(TText text, TValue value)
        {
            Text = text;
            Value = value;
        }
        public TText Text { get; set; }
        public TValue Value { get; set; }
    }

    public class TextValuePair : TextValuePair<string, int>
    {
        public TextValuePair()
        {
        }
        public TextValuePair(string text, int value) : base(text, value)
        {
        }
    }
}
