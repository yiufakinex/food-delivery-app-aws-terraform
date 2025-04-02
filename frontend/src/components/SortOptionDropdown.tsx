import { Button } from "./ui/button";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuTrigger,
} from "./ui/dropdown-menu";

type Props = {
    onChange: (value: string) => void;
    sortOption: string;
};

const SORT_OPTIONS = [
    {
        label: "Best match",
        value: "bestMatch",
    },
    {
        label: "Delivery price",
        value: "deliveryPrice",
    },
    {
        label: "Estimated delivery time",
        value: "estimatedDeliveryTime",
    },
];

const SortOptionDropdown = ({ onChange, sortOption }: Props) => {
    const selectedSortLabel =
        SORT_OPTIONS.find((option) => option.value === sortOption)?.label ||
        SORT_OPTIONS[0].label;
    /*using a find via array method to perform a search on the option to find the object where the option 
    value is equal to the sort option that we received as props so whenever we do find it return the whole
    object so then at this point we can say .label to get the label from that object and we add a conditional here
    to say if any of this was undefined for some reason then just take the first one.*/

    return (
        <DropdownMenu>
            <DropdownMenuTrigger className="cursor-pointer">
                <Button variant="outline" className="w-full">
                    Sort by: {selectedSortLabel}
                </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent>
                {SORT_OPTIONS.map((option) => (
                    <DropdownMenuItem
                        className="cursor-pointer"
                        onClick={() => onChange(option.value)}
                    >
                        {option.label}
                    </DropdownMenuItem>
                ))}
            </DropdownMenuContent>
        </DropdownMenu>
    );
};

export default SortOptionDropdown;