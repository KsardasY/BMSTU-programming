import java.util.Optional;

public class Range {
    public double left;
    public double right;

    public Range(double left, double right)
    {
        this.left = left;
        this.right = right;
    }

    public Boolean entry(Range other)
    {
        return (this.left <= other.left && other.right <= this.right);
    }

    public Optional<Range> intersection(Range other)
    {
        if (other.left <= this.left) {
            if (other.right <= this.left) return Optional.empty();
            else {
                return (other.right <= this.right) ? Optional.of(new Range(this.left, other.right)) : Optional.of(new Range(this.left, this.right));
            }
        } else {
            if (other.left >= this.right) return Optional.empty();
            else {
                return (other.right >= this.right) ? Optional.of(new Range(other.left, this.right)) : Optional.of(new Range(other.left, other.right));
            }
        }
    }

    public Boolean between(double point)
    {
        return (this.left <= point && point <= this.right);
    }

    @Override
    public String toString() {
        return String.format("(%f, %f)", this.left, this.right);
    }
}
