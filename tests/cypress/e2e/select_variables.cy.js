describe("Select variables", () => {
  it("'Select variables'", () => {
    cy.visit("/");
    cy.get("#app-import_file-file").should('be.visible');
    cy.get('#app-import_file-upload_file')
      .should('not.be.visible')
      .selectFile('cypress/fixtures/csv_example.csv', {force: true});
    cy.get('#app-table_output-data_table').wait(5000);
    cy.get('#app-select_variables-forecast_variable').click();
    cy.get('#app-select_variables-forecast_variable-list0').should('be.visible');
    cy.get("#app-select_variables-forecast_variable-list0").should("have.text", "");
    cy.get('#app-select_variables-forecast_variable-list1').should('be.visible');
    cy.get("#app-select_variables-forecast_variable-list1").should("have.text", "Date");
    cy.get('#app-select_variables-forecast_variable-list2').should('be.visible');
    cy.get("#app-select_variables-forecast_variable-list2").should("have.text", "Value1");
    cy.get('#app-select_variables-forecast_variable-list3').should('be.visible');
    cy.get("#app-select_variables-forecast_variable-list3").should("have.text", "Value2");
    cy.get("#app-select_variables-forecast_variable-list2").click();
    
    cy.log('Testing page buttons visibility');
    cy.get('#app-page_buttons-prevtbutton').should('be.visible');
    cy.get('#app-page_buttons-prevtbutton').should('be.disabled');
    cy.get('#app-page_buttons-nextbutton').should('be.visible');
    cy.get('#app-page_buttons-nextbutton').should('not.be.disabled');
      
    cy.log('Continue select variables test');
    cy.get("#app-select_variables-sequence_variable").click();
    cy.get('#app-select_variables-sequence_variable-list0').should('be.visible');
    cy.get("#app-select_variables-sequence_variable-list0").should("have.text", "");
    cy.get('#app-select_variables-sequence_variable-list1').should('be.visible');
    cy.get("#app-select_variables-sequence_variable-list1").should("have.text", "Date");
    cy.get('#app-select_variables-sequence_variable-list2').should('be.visible');
    cy.get("#app-select_variables-sequence_variable-list2").should("have.text", "Value1");
    cy.get('#app-select_variables-sequence_variable-list3').should('be.visible');
    cy.get("#app-select_variables-sequence_variable-list3").should("have.text", "Value2");
    cy.get("#app-select_variables-sequence_variable-list1").click();
    
    cy.log('Testing page buttons visibility');
    cy.get('#app-page_buttons-prevtbutton').should('not.be.visible');
    cy.get('#app-page_buttons-nextbutton').should('not.be.visible');
    
    cy.log('Continue select variables test');
    cy.get('#app-select_variables-forecast_variable').click();
    cy.get('#app-select_variables-forecast_variable-list1').should('be.disabled');
  });
});