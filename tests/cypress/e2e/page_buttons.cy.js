describe("Page buttons", () => {
    beforeEach(() => {
      cy.visit("/");
      //Importing a data to test
      cy.importing_data_flow();
    });
    it("'Page buttons' turning pannel", () => {
        cy.get('#app-page_buttons-nextbutton').should('be.visible');
        cy.get('#app-page_buttons-nextbutton').click();
        cy.get('#app-page_buttons-prevtbutton').should('be.visible');
        cy.get('#app-page_buttons-prevtbutton').should('not.be.disabled');
        cy.get('#app-page_buttons-nextbutton').should('be.visible');
        cy.get('#app-page_buttons-nextbutton').should('be.disabled');
    });
});