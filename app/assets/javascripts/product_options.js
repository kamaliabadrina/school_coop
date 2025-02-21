let optionCount = 0; // Track the number of options added
document.getElementById("add_option").addEventListener("click", function() {
  const optionsDiv = document.getElementById("options");
  const newOption = document.createElement("div");
  newOption.classList.add("option");
  newOption.innerHTML = `
    <label>Option Name</label>
    <input type="text" name="product[product_options_attributes][${optionCount}][name]">
    <h4>Values</h4>
    <div class="option_values">
      <input type="text" name="product[product_options_attributes][${optionCount}][product_option_values_attributes][0][value]" placeholder="Value">
    </div>
    <button type="button" class="add_value">Add Value</button>
    <input type="checkbox" name="product[product_options_attributes][${optionCount}][_destroy]"> Remove this option
  `;
  optionsDiv.appendChild(newOption);
  optionCount++; // Increment count for next option
});

// Add event listener for dynamically added "Add Value" buttons
document.addEventListener('click', function(event) {
  if (event.target.classList.contains('add_value')) {
    const optionDiv = event.target.closest('.option');
    const valuesDiv = optionDiv.querySelector('.option_values');
    const valueCount = valuesDiv.childElementCount; // Get the count of existing values
    const newValue = document.createElement('div');
    newValue.classList.add('value');
    newValue.innerHTML = `
      <label>Value</label>
      <input type="text" name="product[product_options_attributes][${optionCount}][product_option_values_attributes][${valueCount}][value]" placeholder="Value">
      <input type="checkbox" name="product[product_options_attributes][${optionCount}][product_option_values_attributes][${valueCount}][_destroy]"> Remove this value
    `;
    valuesDiv.appendChild(newValue);
  }
});
